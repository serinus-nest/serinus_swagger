import 'dart:io';

import 'components/components.dart';

class ApiSpec {

  final List<String> tags;
  final List<ApiResponse> responses;
  final RequestBody? requestBody;
  final String? operationId;
  final String? summary;
  final String? description;
  final List<ParameterObject> parameters;

  const ApiSpec({
    required this.responses,
    this.tags = const [],
    this.operationId,
    this.requestBody,
    this.summary,
    this.description,
    this.parameters = const [],
  });

  Iterable<ParameterObject> intersectQueryParameters(Map<String, Type> queryParameters) {
    return queryParameters.entries.map((value) {
      final param = parameters.where((element) => element.name == value.key).firstOrNull;
      if(param != null) {
        return param;
      }
      return ParameterObject(
        name: value.key,
        in_: SpecParameterType.query,
      );
    });
  }

}

class ApiResponse {

  final int code;
  final ResponseObject content;
  
  const ApiResponse({
    required this.code,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      '$code': content.toJson()
    };
  }

}

class ApiContent {

  final ContentType type;
  final SchemaObject schema;

  const ApiContent({
    required this.type,
    required this.schema,
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