import 'package:serinus_swagger/src/api_spec.dart';
import 'package:yaml_writer/yaml_writer.dart';

class SwaggerUi {

  final String url;
  final String title;
  final String description;

  SwaggerUi({
    required this.url,
    required this.title,
    required this.description,
  });

  String call() {
    return ''' 
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <meta
            name="description"
            content="$description"
          />
          <title>$title</title>
          <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui.css" />
        </head>
        <body>
          <div id="swagger-ui"></div>
          <script src="https://unpkg.com/swagger-ui-dist@4.5.0/swagger-ui-bundle.js" crossorigin></script>

          <script>
            window.onload = () => {
              window.ui = SwaggerUIBundle({
                dom_id: '#swagger-ui',
                docExpansion: 'list',
                deepLinking: false,
                url: "$url",
                syntaxHighlight: {
                  activate: true,
                  theme: 'agate',
                },
                persistAuthorization: false,
              });
            };
          </script>
        </body>
      </html>
    ''';
  }

}

class SwaggerYamlSpec {

  final String title;
  final String version;
  final String description;
  final String host;
  final String basePath;
  final List<PathObject> paths;
  final Map<String, List<Component>> components;
  final List<Map<String, List<dynamic>>> security;

  SwaggerYamlSpec({
    required this.title,
    required this.version,
    required this.description,
    required this.host,
    required this.basePath,
    required this.paths,
    this.components = const {},
    this.security = const [],
  });

  String call() {
    final writer = YamlWriter();
    final doc = writer.write({
      'openapi': '3.0.0',
      'info': {
        'title': title,
        'version': version,
        'description': description,
      },
      'paths': preparePathObj(),
      'components': generateRecursiveComponent(),
      'security': security,
    });
    
    return doc.toString();
  }

  Map<String, dynamic> generateRecursiveComponent(){
    final Map<String, dynamic> componentsObj = {};
    for (final key in components.keys) {
      final List<Component> componentsList = components[key]!;
      final Map<String, dynamic> componentObj = {};
      for (final component in componentsList) {
        componentObj[component.name] = component.value;
      }
      componentsObj[key] = componentObj;
    }
    return componentsObj;
  }

  Map<String, dynamic> preparePathObj(){
    final Map<String, dynamic> pathsObj = {};
    for (final obj in paths) {
      final Map<String, dynamic> pathObj = {};
      for (final method in obj.methods) {
        final Map<String, dynamic> methodObj = {};
        if(method.summary != null) methodObj['summary'] = method.summary;
        if(method.description != null) methodObj['description'] = method.description;
        methodObj['tags'] = method.tags;
        final Map<String, dynamic> responsesObj = {};
        for (final response in method.responses) {
          final Map<String, dynamic> responseObj = {};
          responseObj['description'] = response.description;
          final Map<String, dynamic> contentObj = {};
          for (final content in response.content) {
            final Map<String, dynamic> schemaObj = {};
            schemaObj['type'] = content.type.mimeType;
            schemaObj['schema'] = parseContentSchema(content.schema);
            contentObj[content.type.mimeType] = schemaObj;
          }
          responseObj['content'] = contentObj;
          responsesObj['${response.code}'] = responseObj;
        }
        if(method.requestBody != null) {
          final Map<String, dynamic> requestBodyObj = {};
          requestBodyObj['required'] = method.requestBody!.required;
          requestBodyObj['content'] = {};
          for (final content in method.requestBody!.content) {
            final Map<String, dynamic> schemaObj = {};
            schemaObj['schema'] = parseContentSchema(content.schema);
            requestBodyObj['content'][content.type.mimeType] = schemaObj;
          }
          methodObj['requestBody'] = requestBodyObj;
        }
        methodObj['responses'] = responsesObj;
        pathObj[method.method] = methodObj;
        pathObj['parameters'] = method.parameters.where((element) => !element.ignore).toList();
      }
      pathsObj[obj.path] = pathObj;
    }
    return pathsObj;
  }

  Map<String, dynamic> parseContentSchema(ContentSchema schema){
    final Map<String, dynamic> schemaObj = {};
    final String type = schema.type.toString().split('.').last;
    if(type == 'ref'){
      schemaObj['\$ref'] = '#/components/schemas/${schema.value}';
    }else{
      schemaObj['type'] = type == 'text' ? 'string' : type;
    }
    if(schema.type == ContentSchemaType.object){
      if(schema.value != null){
        final Map<String, dynamic> propertiesObj = {};
        for (final key in schema.value!.keys) {
          propertiesObj[key] = parseContentSchema(schema.value![key]!);
        }
        schemaObj['properties'] = propertiesObj;
      } 
    }
    if(schema.example != null){
      schemaObj['example'] = schema.getExample();
    }
    return schemaObj;
  }

}

class PathObject {

  final String path;
  final List<PathMethod> methods;

  PathObject({
    required this.path,
    this.methods = const [],
  });

}

class PathMethod {
  
    final String method;
    final String? summary;
    final String? description;
    final List<String> tags;
    final List<ApiResponse> responses;
    final List<ApiSpecParameter> parameters;
    final RequestBody? requestBody;
  
    PathMethod({
      required this.method,
      required this.tags,
      required this.responses,
      this.summary,
      this.description,
      this.parameters = const [],
      this.requestBody
    });
}

class Component<T> {

  final String name;
  final T? value;

  Component({
    required this.name,
    required this.value,
  }) {
    if(value == null) throw Exception('Component value cannot be null');
  }

  Map<String, dynamic> toJson(){
    return {
      name: value
    };
  }

}