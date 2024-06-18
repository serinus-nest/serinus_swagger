import 'dart:io';

import 'package:serinus_swagger/serinus_swagger.dart';
import 'package:serinus/serinus.dart';
import 'package:serinus_swagger/src/swagger_ui.dart';

class HelloWorldRoute extends ApiRoute {

  HelloWorldRoute({super.queryParameters}) : super(
    path: '/',
    apiSpec: ApiSpec(
      parameters: [
        ApiSpecParameter(
          name: 'name',
          type: SpecParameterType.query,
          required: false,
        )
      ],
      responses: [
        ApiResponse(
          code: 200,
          description: 'Hello world response',
          content: [
            ApiContent(
              type: ContentType.text,
              schema: ContentSchema(
                type: ContentSchemaType.text,
                example: ContentSchemaValue<String>(value: 'Post route')
              )
            )
          ]
        ),
      ]
    )
  );
}

class PostRoute extends ApiRoute {

  PostRoute({required super.path}) : super(
    apiSpec: ApiSpec(
      requestBody: RequestBody(
        required: false,
        content: [
          ApiContent(
            type: ContentType.json,
            schema: ContentSchema(
              type: ContentSchemaType.ref,
              value: 'User'
            )
          )
        ]
      ),
      responses: [
        ApiResponse(
          code: 200,
          description: 'Post response',
          content: [
            ApiContent(
              type: ContentType.json,
              schema: ContentSchema(
                type: ContentSchemaType.ref,
                value: 'User'
              )
            ),
            ApiContent(
              type: ContentType.text,
              schema: ContentSchema(
                type: ContentSchemaType.text,
                example: ContentSchemaValue<String>(value: 'Post route')
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
    on(PostRoute(path: '/post/<data>'), (context) async => Response.json({'message': 'Post ${context.pathParameters['data']}'}));
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
  final swagger = await SwaggerModule.create(
    app, 
    document,
    components: [
      Component(
        name: 'User', 
        value: ContentSchema(
          type: ContentSchemaType.object, 
          value: {
            'name': ContentSchema(),
            'age': ContentSchema(type: ContentSchemaType.integer),
            'email': ContentSchema(),
          }
        )
      ),
      Component<SecuritySchema>(
        name: 'apiKeyScheme',
        value: SecuritySchema(
          type: SecuritySchemaType.apiKey,
          name: 'Authorization',
          inType: SpecParameterType.header
        )
      )
    ]
  );
  await swagger.setup(
    '/api',
  );
  await app.serve();
}