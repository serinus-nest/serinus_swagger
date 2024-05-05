import 'dart:io';

import 'package:serinus/serinus.dart';

class SwaggerRoute extends Route {
  SwaggerRoute({
    super.path = '/',
  }): super(method: HttpMethod.get);
}

class SwaggerController extends Controller {

  final String swaggerHtml;

  SwaggerController({
    required this.swaggerHtml,
    required super.path
  }){
    on(SwaggerRoute(), (context) async => Response.html(swaggerHtml, contentType: ContentType.html));
    on(SwaggerRoute(path: '/swagger.yaml'), (context) async {
      final file = File('swagger.yaml');
      if(!file.existsSync()){
        throw NotFoundException(message: 'Swagger file not found');
      }
      return Response.text(await file.readAsString());
    });
  }
}

class SwaggerUiModule extends Module {
  
  final String swaggerHtml;
  final String finalPath;

  SwaggerUiModule(this.finalPath, this.swaggerHtml): super(
    controllers: [
      SwaggerController(swaggerHtml: swaggerHtml, path: finalPath)
    ]
  );
  
}

