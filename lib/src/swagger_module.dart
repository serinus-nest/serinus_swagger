import 'dart:io';

import 'package:serinus/serinus.dart';
import 'package:serinus_swagger/src/components/response_object.dart';

import 'api_route.dart';
import 'api_spec.dart';
import 'components/components.dart';
import 'document.dart';
import 'swagger_ui.dart';
import 'swagger_ui_module.dart';


class SwaggerModule {
  
  final Application app;
  final DocumentSpecification document;
  SwaggerYamlSpec? _swaggerYamlSpec;
  SwaggerUiModule? _swaggerUiModule;
  String? _swaggerUrl;
  final List<Component>? components;


  static Future<SwaggerModule> create(
    Application app, 
    DocumentSpecification document,
    {
      List<Component>? components,
    }
  ) async {
    final swagger = SwaggerModule._(app, document, components);
    await swagger.exploreModules();
    return swagger;
  }

  SwaggerModule._(this.app, this.document, this.components);

  Future<void> exploreModules() async {
    await app.register();
    final paths = <PathObject>[];
    final globalPrefix = app.config.globalPrefix;
    final versioning = app.config.versioningOptions;
    final controllers = <Controller>[];
    for(final module in app.modulesContainer.modules){
      controllers.addAll(module.controllers);
    }
    for(final controller in controllers){
      final controllerPath = controller.path;
      final controllerName = controller.runtimeType;
      for(final route in controller.routes.keys){
        final pathParameters = <ParameterObject>[];
        final routePath = route.path.split('/');
        for(final path in routePath){
          if(path.startsWith('<') && path.endsWith('>')){
            final pathName = path.substring(1, path.length - 1);
            routePath[routePath.indexOf(path)] = '{$pathName}';
            pathParameters.add(
              ParameterObject(
                name: pathName, 
                in_: SpecParameterType.path,
                required: true,
              )
            );
          }
        }
        final routeMethod = route.method;
        StringBuffer sb = StringBuffer();
        if(globalPrefix != null){
          sb.write('/$globalPrefix');
        }
        if(versioning != null && versioning.type == VersioningType.uri){
          sb.write('/v${versioning.version}');
        }
        sb.write('/$controllerPath');
        sb.write('/${routePath.join('/')}');
        final finalPath = normalizePath(sb.toString());
        final pathObj = paths.firstWhere((element) => element.path == finalPath, orElse: () => PathObject(path: finalPath, methods: []));
        if(route.route is ApiRoute) {
          final apiSpec = (route.route as ApiRoute).apiSpec;
          final parameters = [
            ...apiSpec.parameters,
            ...apiSpec.intersectQueryParameters(route.route.queryParameters),
            ...pathParameters
          ];
          pathObj.methods.add(PathMethod(
            method: routeMethod.name.toLowerCase(), 
            tags: List<String>.from({
              ...apiSpec.tags,
              '$controllerName'
            }), 
            responses: apiSpec.responses,
            requestBody: apiSpec.requestBody,
            parameters: {
              for(final param in parameters) param.name: param
            }.values.toList(),
            summary: apiSpec.summary,
            description: apiSpec.description
          ));
        }else{
          pathObj.methods.add(PathMethod(
            method: routeMethod.name.toLowerCase(), 
            tags: ['$controllerName'], 
            responses: [
              ApiResponse(
                code: 200,
                content: ResponseObject(
                  description: 'Success response',
                  content: []
                )
              )
            ]
          ));
        }
        if(!paths.contains(pathObj)){
          paths.add(pathObj);
        }
      }

    }
    final List<Component<SecurityObject>> securitySchema = List<Component<SecurityObject>>.from(
      components?.where((element) => element.value is SecurityObject) ?? <Component<SecurityObject>>[]
    );
    if(document.securitySchema != null){
      securitySchema.add(document.securitySchema!);
    }
    _swaggerYamlSpec = SwaggerYamlSpec(
      document: document,
      host: 'localhost:8080',
      basePath: '/',
      paths: paths,
      components: {
        'schemas': components?.where((element) => element.value is SchemaObject).toList() ?? [],
        'securitySchemes': securitySchema,
        'responses': components?.where((element) => element.value is ResponseObject).toList() ?? [],
        'parameters': components?.where((element) => element.value is ParameterObject).toList() ?? [],
        'requestBodies': components?.where((element) => element.value is RequestBody).toList() ?? [],
        'headers': components?.where((element) => element.value is HeaderObject).toList() ?? [],
        'examples': components?.where((element) => element.value is ExampleObject).toList() ?? [],
      },
      security: securitySchema.where((element) => element.value?.isDefault ?? false).map((e) => {e.name: []}).toList()
    );
    await File('swagger.yaml').writeAsString(_swaggerYamlSpec!());
    StringBuffer sb = StringBuffer();
    if(globalPrefix != null){
      sb.write('/$globalPrefix');
    }
    if(versioning != null && versioning.type == VersioningType.uri){
      sb.write('/v${versioning.version}');
    }
    sb.write('/{{endpoint}}');
    sb.write('/swagger.yaml');
    _swaggerUrl = '${app.config.baseUrl}${normalizePath(sb.toString())}';
  }

  Future<void> setup(String endpoint) async {
    final swaggerHtml = SwaggerUi(
      title: _swaggerYamlSpec!.document.title,
      description: _swaggerYamlSpec!.document.description,
      url: _swaggerUrl!.replaceAll('{{endpoint}}', endpoint.replaceAll('/', ''))
    );
    _swaggerUiModule = SwaggerUiModule(endpoint, swaggerHtml());
    await app.modulesContainer.registerModules(_swaggerUiModule!, app.modulesContainer.modules.last.runtimeType);
  }

  String normalizePath(String path) {
    if (!path.startsWith("/")) {
      path = "/$path";
    }
    if (path.endsWith("/") && path.length > 1) {
      path = path.substring(0, path.length - 1);
    }
    if (path.contains(RegExp('([/]{2,})'))) {
      path = path.replaceAll(RegExp('([/]{2,})'), '/');
    }
    return path;
  }

}
