import 'dart:io';

import 'package:serinus/serinus.dart';

class SwaggerController extends Controller {

  final String swaggerHtml;

  SwaggerController({
    required this.swaggerHtml,
    required super.path
  }){
    on(Route.get('/'), (context) async => Response.html(swaggerHtml, contentType: ContentType.html));
    on(Route.get('/swagger.yaml'), (context) async {
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

