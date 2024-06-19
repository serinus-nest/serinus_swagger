import 'package:serinus/serinus.dart';

import 'api_spec.dart';
import 'components/components.dart';

class ApiRoute extends Route {

  final ApiSpec apiSpec;

  const ApiRoute({
    required super.path,
    required this.apiSpec,
    super.method = HttpMethod.get,
    super.queryParameters,
  });

  factory ApiRoute.get({
    required String path,
    required ApiResponse response,
    RequestBody? requestBody,
    Map<String, Type> queryParameters = const {},
  }) {
    return ApiRoute(
      path: path,
      apiSpec: ApiSpec(
        responses: [response],
        requestBody: requestBody,
        parameters: queryParameters.entries.map((value) => ParameterObject(
          name: value.key,
          in_: SpecParameterType.query,
        )).toList(),
      ),
      queryParameters: queryParameters
    );
  }

  factory ApiRoute.post({
    required String path,
    required ApiResponse response,
    RequestBody? requestBody,
    Map<String, Type> queryParameters = const {},
  }) {
    return ApiRoute(
      path: path,
      apiSpec: ApiSpec(
        responses: [response],
        requestBody: requestBody,
        parameters: queryParameters.entries.map((value) => ParameterObject(
          name: value.key,
          in_: SpecParameterType.query,
        )).toList(),
      ),
      method: HttpMethod.post,
      queryParameters: queryParameters
    );
  }

  factory ApiRoute.put({
    required String path,
    required ApiResponse response,
    RequestBody? requestBody,
    Map<String, Type> queryParameters = const {},
  }) {
    return ApiRoute(
      path: path,
      apiSpec: ApiSpec(
        responses: [response],
        requestBody: requestBody,
        parameters: queryParameters.entries.map((value) => ParameterObject(
          name: value.key,
          in_: SpecParameterType.query,
        )).toList(),
      ),
      method: HttpMethod.put,
      queryParameters: queryParameters
    );
  }

  factory ApiRoute.delete({
    required String path,
    required ApiResponse response,
    RequestBody? requestBody,
    Map<String, Type> queryParameters = const {},
  }) {
    return ApiRoute(
      path: path,
      apiSpec: ApiSpec(
        responses: [response],
        requestBody: requestBody,
        parameters: queryParameters.entries.map((value) => ParameterObject(
          name: value.key,
          in_: SpecParameterType.query,
        )).toList(),
      ),
      method: HttpMethod.delete,
      queryParameters: queryParameters
    );
  }

  factory ApiRoute.patch({
    required String path,
    required ApiResponse response,
    RequestBody? requestBody,
    Map<String, Type> queryParameters = const {},
  }) {
    return ApiRoute(
      path: path,
      apiSpec: ApiSpec(
        responses: [response],
        requestBody: requestBody,
        parameters: queryParameters.entries.map((value) => ParameterObject(
          name: value.key,
          in_: SpecParameterType.query,
        )).toList(),
      ),
      method: HttpMethod.patch,
      queryParameters: queryParameters
    );
  }

}