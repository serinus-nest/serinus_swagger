import '../api_spec.dart';
import 'component.dart';

final class SecurityObject extends ComponentValue {

  final SecurityType type;
  final SecurityScheme? scheme;
  final String? bearerFormat;
  final SpecParameterType? inType;
  final String? name;
  final bool isDefault;
  final FlowsObject? flows;
  final String? openIdConnectUrl;

  SecurityObject({
    required this.type,
    this.scheme,
    this.bearerFormat,
    this.inType,
    this.name,
    this.isDefault = true,
    this.flows,
    this.openIdConnectUrl,
  }) {
    if(type == SecurityType.apiKey && inType == null) {
      throw Exception('inType must be provided for apiKey type');
    }
    if(type == SecurityType.apiKey && name == null) {
      throw Exception('name must be provided for apiKey type');
    }
    if(
      type == SecurityType.apiKey && ![
        SpecParameterType.header, 
        SpecParameterType.cookie, 
        SpecParameterType.query
      ].contains(inType)
    ) {
      throw Exception('inType must be header, cookie or query for apiKey type');
    }
    if(type == SecurityType.http && scheme == null) {
      throw Exception('scheme must be provided for http type');
    }
    if(type == SecurityType.http && scheme == SecurityScheme.bearer && bearerFormat == null) {
      throw Exception('bearerFormat must be provided for bearer scheme');
    }
    if(type == SecurityType.oauth2 && flows == null) {
      throw Exception('flows must be provided for oauth2 type');
    }
    if(type == SecurityType.openIdConnect && openIdConnectUrl == null) {
      throw Exception('openIdConnectUrl must be provided for openIdConnect type');
    }
  }

  SecurityObject setAsDefault({
    bool isDefault = true,
  }) {
    return SecurityObject(
      type: type,
      scheme: scheme,
      bearerFormat: bearerFormat,
      inType: inType,
      name: name,
      isDefault: isDefault,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> schemaObj = {
      'type': type.toString().split('.').last,
    };
    if(type == SecurityType.apiKey) {
      schemaObj['in'] = inType.toString().split('.').last;
      schemaObj['name'] = name;
    }
    if(type == SecurityType.http) {
      schemaObj['scheme'] = scheme.toString().split('.').last;
      if(scheme == SecurityScheme.bearer) {
        schemaObj['bearerFormat'] = bearerFormat;
      }
    }
    if(flows != null) {
      schemaObj['flows'] = flows!.toJson();
    }
    if(openIdConnectUrl != null) {
      schemaObj['openIdConnectUrl'] = openIdConnectUrl;
    }
    return schemaObj;
  }

}

enum SecurityType {
  apiKey,
  http,
  oauth2,
  openIdConnect,
}

enum SecurityScheme {
  bearer,
  basic,
}

class FlowsObject {

  final ImplicitFlowObject? implicit;
  final CredentialsFlowObject? password;
  final CredentialsFlowObject? clientCredentials;
  final AuthorizationCodeFlowObject? authorizationCode;

  FlowsObject({
    this.implicit,
    this.password,
    this.clientCredentials,
    this.authorizationCode,
  });

  Map<String, dynamic> toJson() {
    return {
      if(implicit != null) 'implicit': implicit!.toJson(),
      if(password != null) 'password': password!.toJson(),
      if(clientCredentials != null) 'clientCredentials': clientCredentials!.toJson(),
      if(authorizationCode != null) 'authorizationCode': authorizationCode!.toJson(),
    };
  }

}

final class ImplicitFlowObject {

  final String? authorizationUrl;
  final String refreshUrl;
  final Map<String, String> scopes;

  ImplicitFlowObject({
    this.authorizationUrl,
    this.refreshUrl = '',
    this.scopes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'authorizationUrl': authorizationUrl,
      if(refreshUrl.isNotEmpty) 'refreshUrl': refreshUrl,
      'scopes': scopes,
    };
  }

}

final class AuthorizationCodeFlowObject {

  final String authorizationUrl;
  final String tokenUrl;
  final String refreshUrl;
  final Map<String, String> scopes;

  AuthorizationCodeFlowObject({
    required this.authorizationUrl,
    required this.tokenUrl,
    this.refreshUrl = '',
    this.scopes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'authorizationUrl': authorizationUrl,
      'tokenUrl': tokenUrl,
      if(refreshUrl.isNotEmpty) 'refreshUrl': refreshUrl,
      'scopes': scopes,
    };
  }

}

final class CredentialsFlowObject {

  final String tokenUrl;
  final String refreshUrl;
  final Map<String, String> scopes;

  CredentialsFlowObject({
    required this.tokenUrl,
    this.refreshUrl = '',
    this.scopes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'tokenUrl': tokenUrl,
      if(refreshUrl.isNotEmpty) 'refreshUrl': refreshUrl,
      'scopes': scopes,
    };
  }

}

