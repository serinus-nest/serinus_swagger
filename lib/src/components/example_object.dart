import 'components.dart';

final class ExampleObject extends DescriptiveObject {

  final dynamic value;
  final String? summary;
  final String? description;

  ExampleObject({
    required this.value,
    this.summary,
    this.description,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if(summary != null) 'summary': summary,
      if(description != null) 'description': description,
    };
  }

}