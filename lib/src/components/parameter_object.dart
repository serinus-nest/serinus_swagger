import 'components.dart';
import '../api_spec.dart';


class ParameterObject extends DescriptiveObject {

  final String name;
  final SpecParameterType in_;
  final String? description;
  final bool required;
  final bool deprecated;
  final SchemaObject? schema;
  final Map<String, DescriptiveObject> examples;

  ParameterObject({
    required this.name,
    required this.in_,
    this.description,
    this.required = false,
    this.deprecated = false,
    this.examples = const {},
    this.schema,
  }) {
    if(in_ == SpecParameterType.path && required == false) {
      throw ArgumentError('Path parameters must be required');
    }
  }

  bool get ignore {
    return in_ == SpecParameterType.header && ['accept', 'content-type', 'authorization'].contains(name.toLowerCase());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'in': in_.toString().split('.').last,
      if(description != null) 'description': description,
      'schema': schema?.toJson() ?? {},
      'required': required,
      'deprecated': deprecated,
      if(examples.isNotEmpty) 'examples': examples.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

}