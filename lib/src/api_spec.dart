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
  final List<ApiSpecParameter> parameters;

  ApiSpec({
    required this.responses,
    this.tags = const [],
    this.operationId,
    this.summary,
    this.description,
    this.parameters = const [],
  });

  Iterable<ApiSpecParameter> intersectQueryParameters(Map<String, Type> queryParameters){
    return queryParameters.entries.map((value) {
      final param = parameters.where((element) => element.name == value.key).firstOrNull;
      if(param != null){
        return param;
      }
      return ApiSpecParameter(
        name: value.key,
        type: SpecParameterType.query,
      );
    });
  }

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

class ContentSchema<T> {

  final ContentSchemaType type;
  final ContentSchemaValue<T>? example;
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

  dynamic getExample() {
    switch(type) {
      case ContentSchemaType.text:
        return example?.value.toString() ?? '';
      case ContentSchemaType.object:
        final Map<String, dynamic> obj = {};
        for(final key in properties!.keys){
          obj[key] = properties![key]!.getExample();
        }
        return obj;
      case ContentSchemaType.ref:
        return example?.value.toString() ?? '';
      case ContentSchemaType.array:
        return [...(properties?.values.map((e) => e.getExample()) ?? [])];
      case ContentSchemaType.number:
        return example?.value ?? 0;
      case ContentSchemaType.integer:
        return example?.value ?? 0;
      case ContentSchemaType.boolean:
        return example?.value ?? false;
      default:
        return {};
    } 
  }

}

class ContentSchemaValue<T> {

  final T value;

  const ContentSchemaValue({
    required this.value,
  });

}

enum SpecParameterType {
  query,
  path,
  header,
  cookie,
}

class ApiSpecParameter {

  final String name;
  final SpecParameterType type;
  final bool required;
  final bool deprecated;
  final String? description;
  final bool allowEmptyValue;

  ApiSpecParameter({
    required this.name,
    required this.type,
    this.required = false,
    this.deprecated = false,
    this.description,
    this.allowEmptyValue = false,
  }){
    if(type == SpecParameterType.path && required == false){
      throw Exception('Path parameters must be required');
    }
    if(type != SpecParameterType.query && allowEmptyValue == true){
      throw Exception('Empty value is only allowed for query parameters');
    }
  }

  bool get ignore {
    return type == SpecParameterType.header && ['accept', 'content-type', 'authorization'].contains(name.toLowerCase());
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'in': type.toString().split('.').last,
      'required': required,
      'deprecated': deprecated,
      'description': description,
      'allowEmptyValue': allowEmptyValue,
    };
  }

}