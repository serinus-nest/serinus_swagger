import 'dart:io';

import 'package:serinus/serinus.dart';

abstract class ApiSpecRoute extends Route {

  final ApiSpec apiSpec;

  ApiSpecRoute({
    required super.path,
    required this.apiSpec,
    super.method = HttpMethod.get,
    super.queryParameters,
  });
}

class ApiSpec {

  final List<String> tags;
  final List<ApiResponse> responses;
  final String? operationId;
  final String? summary;
  final String? description;

  ApiSpec({
    required this.responses,
    this.tags = const [],
    this.operationId,
    this.summary,
    this.description,
  });

}

class ApiResponse {
  final int code;
  final String description;
  final List<ApiResponseContent> content;

  ApiResponse({
    required this.code,
    required this.description,
    required this.content,
  });

}

class ApiResponseContent {
  final ContentType type;
  final ContentSchema schema;

  ApiResponseContent({
    required this.type,
    required this.schema,
  });
}

enum ContentSchemaType {
  text,
  object,
  ref,
  array,
  number,
  integer,
  boolean,
}

class ContentSchema {

  final ContentSchemaType type;
  final dynamic example;
  final Map<String, ContentSchema>? properties;

  ContentSchema({
    this.type = ContentSchemaType.text,
    this.example,
    this.properties
  }){
    if(type == ContentSchemaType.object){
      if(properties == null){
        throw Exception('Properties must be provided for object type');
      }
      if(example != null && example is! Map){
        throw Exception('Example must be a map for object type');
      }
    }
  }

}