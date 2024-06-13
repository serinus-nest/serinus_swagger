import 'dart:io';

import 'package:serinus/serinus.dart';

abstract class ApiSpecRoute extends Route {

  final ApiSpec apiSpec;

  const ApiSpecRoute({
    required super.path,
    required this.apiSpec,
    super.method = HttpMethod.get,
    super.queryParameters,
  });
}

class ApiSpec {

  final List<String> tags;
  final List<ApiResponse> responses;
  final RequestBody? requestBody;
  final String? operationId;
  final String? summary;
  final String? description;
  final List<ApiSpecParameter> parameters;

  const ApiSpec({
    required this.responses,
    this.tags = const [],
    this.operationId,
    this.requestBody,
    this.summary,
    this.description,
    this.parameters = const [],
  });

  Iterable<ApiSpecParameter> intersectQueryParameters(Map<String, Type> queryParameters) {
    return queryParameters.entries.map((value) {
      final param = parameters.where((element) => element.name == value.key).firstOrNull;
      if(param != null) {
        return param;
      }
      return ApiSpecParameter(
        name: value.key,
        type: SpecParameterType.query,
      );
    });
  }

}

class RequestBody {

  final List<ApiContent> content;
  final bool required;
  final String? description;

  const RequestBody({
    required this.content,
    this.required = true,
    this.description,
  });

}

class ApiResponse {

  final int code;
  final String description;
  final List<ApiContent> content;

  const ApiResponse({
    required this.code,
    required this.description,
    required this.content,
  });

}

class ApiContent {

  final ContentType type;
  final ContentSchema schema;

  const ApiContent({
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
  final dynamic value;

  ContentSchema({
    this.type = ContentSchemaType.text,
    this.example,
    this.value
  }) {
    if(type == ContentSchemaType.object) {
      if(value == null) {
        throw Exception('Properties must be provided for object type');
      }
      if(example != null && example is! Map) {
        throw Exception('Example must be a map for object type');
      }
    }
  }

  dynamic getExample() {
    switch(type) {
      case ContentSchemaType.text:
        return example?.value.toString() ?? '';
      case ContentSchemaType.object:
        return {
          for (final key in value!.keys) key: value![key]!.getExample()
        };
      case ContentSchemaType.ref:
        return example?.value.toString() ?? '';
      case ContentSchemaType.array:
        return [...(value?.map((e) => e.getExample()) ?? [])];
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> schemaObj = {};
    final String t = type.toString().split('.').last;
    if(t == 'ref') {
      schemaObj['\$ref'] = '#/components/schemas/$value';
    }else{
      if(t == 'text') {
        schemaObj['type'] = 'string';
      }else{
        schemaObj['type'] = t;
      }
    }
    if(type == ContentSchemaType.object) {
      if(value != null) {
        final Map<String, dynamic> propertiesObj = {};
        for (final key in value!.keys) {
          propertiesObj[key] = value![key]!.toJson();
        }
        schemaObj['properties'] = propertiesObj;
      }
    }
    return schemaObj;
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
  }) {
    if(type == SpecParameterType.path && required == false) {
      throw Exception('Path parameters must be required');
    }
    if(type != SpecParameterType.query && allowEmptyValue) {
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