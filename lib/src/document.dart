
import 'api_spec.dart';
import 'components/components.dart';

class DocumentSpecification {

  final String title;
  final String version;
  final String description;
  final String? termsOfService;
  Component<SecurityObject>? securitySchema;
  final ContactObject? contact;
  final LicenseObject? license;

  DocumentSpecification({
    required this.title,
    required this.version,
    this.description = '',
    this.contact,
    this.license,
    this.termsOfService,
  });

  void addSecurity(Component<SecurityObject> schema){
    securitySchema = Component(name: schema.name, value: schema.value?.setAsDefault());
  }

  void addBasicAuth(){
    securitySchema = Component(
      name: 'basicAuth',
      value: SecurityObject(
        type: SecurityType.http,
        scheme: SecurityScheme.basic,
      ).setAsDefault()
    );
  }

  void addApiKeyAuth({
    required String name,
    required SpecParameterType inType,
  }){
    securitySchema = Component(
      name: 'apiKeyAuth',
      value: SecurityObject(
        type: SecurityType.apiKey,
        name: name,
        inType: inType,
      ).setAsDefault()
    );
  }

  void addOAuth2Auth({
    required FlowsObject flows,
  }){
    securitySchema = Component(
      name: 'oauth2Auth',
      value: SecurityObject(
        type: SecurityType.oauth2,
        flows: flows,
      ).setAsDefault()
    );
  }

  void addOpenIdConnectAuth({
    required String openIdConnectUrl,
  }){
    securitySchema = Component(
      name: 'openIdConnectAuth',
      value: SecurityObject(
        type: SecurityType.openIdConnect,
        openIdConnectUrl: openIdConnectUrl,
      ).setAsDefault()
    );
  }

  void addBearerAuth({
    required String bearerFormat,
  }){
    securitySchema = Component(
      name: 'bearerAuth',
      value: SecurityObject(
        type: SecurityType.http,
        scheme: SecurityScheme.bearer,
        bearerFormat: bearerFormat,
      ).setAsDefault()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'version': version,
      'description': description,
      if(termsOfService != null) 'termsOfService': termsOfService,
      if(contact != null) 'contact': {
        'name': contact!.name,
        'url': contact!.url,
        'email': contact!.email,
      },
      if(license != null) 'license': license?.toJson()
    };
  }

}

final class ContactObject {
  
  final String name;
  final String url;
  final String email;

  ContactObject({
    required this.name,
    required this.url,
    required this.email,
  });
}

final class LicenseObject {
  
  final String name;
  final String? identifier;
  final String url;

  LicenseObject({
    required this.name,
    this.identifier,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if(identifier != null) 'identifier': identifier,
      'url': url,
    };
  }
  
}