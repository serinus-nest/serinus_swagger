import 'dart:io';

import 'package:serinus_swagger/serinus_swagger.dart';
import 'package:serinus/serinus.dart';

class HelloWorldRoute extends ApiSpecRoute {

  HelloWorldRoute({super.queryParameters}) : super(
    path: '/',
    apiSpec: ApiSpec(
      responses: [
        ApiResponse(
          code: 200,
          description: 'Hello world response',
          content: [
            ApiResponseContent(
              type: ContentType.text,
              schema: ContentSchema(
                type: ContentSchemaType.text,
                example: 'Hello world'
              )
            )
          ]
        ),
      ]
    )
  );
}

class PostRoute extends ApiSpecRoute {

  PostRoute({required super.path}) : super(
    apiSpec: ApiSpec(
      responses: [
        ApiResponse(
          code: 200,
          description: 'Post response',
          content: [
            ApiResponseContent(
              type: ContentType.json,
              schema: ContentSchema(
                type: ContentSchemaType.object,
                properties: {
                  'message': ContentSchema(
                    type: ContentSchemaType.text,
                    example: 'Post route'
                  )
                }
              )
            ),
            ApiResponseContent(
              type: ContentType.text,
              schema: ContentSchema(
                type: ContentSchemaType.text,
                example: 'Post route'
              )
            )
          ]
        )
      ]
    ),
    method: HttpMethod.post
  );
}

class AppController extends Controller {

  AppController({super.path = '/'}){
    on(HelloWorldRoute(
      queryParameters: {
        'name': String,
      }
    ), _handleHelloWorld);
    on(PostRoute(path: '/post'), (context) async => Response.json({'message': 'Post route'}));
  }

  Future<Response> _handleHelloWorld(RequestContext context) async {
    return Response.text('Hello world');
  }

}

class App2Controller extends Controller {

  App2Controller({super.path = '/a'}){
    on(HelloWorldRoute(), _handleHelloWorld);
    on(PostRoute(path: '/post'), (context) async => Response.json({'message': 'Post route'}));
  }

  Future<Response> _handleHelloWorld(RequestContext context) async {
    return Response.text('Hello world');
  }

}

class AppModule extends Module {

  AppModule(): super(
    controllers: [
      AppController(),
      App2Controller()
    ],
    imports: [
      App2Module()
    ]
  );

}

class App2Module extends Module {

  App2Module();

}

void main(List<String> args) async {
  final document = DocumentSpecification(
    title: 'Serinus Test Swagger',
    version: '1.0',
    description: 'API documentation for the Serinus project',
  );

  final app = await serinus.createApplication(
    entrypoint: AppModule(),
  );
  final swagger = await SwaggerModule.create(app, document);
  await swagger.setup('/api');
  await app.serve();
}