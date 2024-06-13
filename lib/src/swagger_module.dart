import 'dart:io';

import 'package:serinus/serinus.dart';
import 'package:serinus_swagger/serinus_swagger.dart';
import 'package:serinus_swagger/src/swagger_ui.dart';
import 'package:serinus_swagger/src/swagger_ui_module.dart';

class SwaggerModule {
  
  final Application app;
  final DocumentSpecification document;
  SwaggerYamlSpec? _swaggerYamlSpec;
  SwaggerUiModule? _swaggerUiModule;
  String? _swaggerUrl;
  final List<Component<ContentSchema>>? schemas;


  static Future<SwaggerModule> create(
    Application app, 
    DocumentSpecification document,
    {
      List<Component<ContentSchema>>? schemas,
    }
  ) async {
    final swagger = SwaggerModule._(app, document, schemas);
    await swagger.exploreModules();
    return swagger;
  }

  SwaggerModule._(this.app, this.document, this.schemas);

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
        final pathParameters = <ApiSpecParameter>[];
        final routePath = route.path.split('/');
        for(final path in routePath){
          if(path.startsWith('<') && path.endsWith('>')){
            final pathName = path.substring(1, path.length - 1);
            routePath[routePath.indexOf(path)] = '{$pathName}';
            pathParameters.add(
              ApiSpecParameter(
                name: pathName, 
                type: SpecParameterType.path,
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
        if(route.route is ApiSpecRoute) {
          final apiSpec = (route.route as ApiSpecRoute).apiSpec;
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
                description: 'Success',
                content: [
                  ApiContent(
                    type: ContentType.text,
                    schema: ContentSchema()
                  )
                ]
              )
            ]
          ));
        }
        if(!paths.contains(pathObj)){
          paths.add(pathObj);
        }
      }

    }
    _swaggerYamlSpec = SwaggerYamlSpec(
      title: document.title,
      version: document.version,
      description: document.description,
      host: 'localhost:8080',
      basePath: '/',
      paths: paths,
      components: {
        'schemas': schemas ?? []
      }
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
      title: _swaggerYamlSpec!.title,
      description: _swaggerYamlSpec!.description,
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
