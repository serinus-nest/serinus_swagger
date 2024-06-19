import 'components.dart';

enum SchemaType {
  text,
  object,
  ref,
  array,
  number,
  integer,
  boolean,
}

class SchemaValue<T> {

  final T value;

  const SchemaValue({
    required this.value,
  });

}

final class SchemaObject<T> extends ComponentValue {

  final SchemaType type;
  final SchemaValue<T>? example;
  final dynamic value;

  SchemaObject({
    this.type = SchemaType.text,
    this.example,
    this.value,
  }) {
    if(type == SchemaType.object) {
      if(value == null) {
        throw Exception('Properties must be provided for object type');
      }
    }
  }

  
  dynamic getExample() {
    switch(type) {
      case SchemaType.text:
        return example?.value.toString() ?? '';
      case SchemaType.object:
        return {
          for (final key in value!.keys) key: value![key]!.getExample()
        };
      case SchemaType.ref:
        print(example?.value.toString() ?? '');
        return example?.value.toString() ?? '';
      case SchemaType.array:
        return [...(value?.map((e) => e.getExample()) ?? [])];
      case SchemaType.number:
        return example?.value ?? 0;
      case SchemaType.integer:
        return example?.value ?? 0;
      case SchemaType.boolean:
        return example?.value ?? false;
      default:
        return {};
    } 
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> schemaObj = {};
    final String t = type.toString().split('.').last;
    if(t == 'ref') {
      print(value);
      schemaObj['\$ref'] = '#/components/$value';
    }else{
      if(t == 'text') {
        schemaObj['type'] = 'string';
      }else{
        schemaObj['type'] = t;
      }
    }
    if(type == SchemaType.object) {
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