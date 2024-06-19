import 'dart:io';

import 'components.dart';

class MediaObject extends ComponentValue {

  final SchemaObject schema;

  final Map<String, DescriptiveObject> examples;

  final ContentType encoding;

  MediaObject({
    required this.schema,
    required this.encoding,
    this.examples = const {},
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      encoding.mimeType: {
        'schema': schema.toJson(),
        'examples': examples.map((key, value) => MapEntry(key, value.toJson())),
      },
    };
  }
  

}