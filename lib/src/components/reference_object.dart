import 'descriptive_object.dart';

class ReferenceObject extends DescriptiveObject {
  ReferenceObject({
    required this.ref,
    this.description,
    this.summary,
  });

  final String ref;
  final String? description;
  final String? summary;

  @override
  Map<String, dynamic> toJson() {
    return {
      '\$ref': ref,
      if(description != null) 'description': description,
      if(summary != null) 'summary': summary,
    };
  }
}