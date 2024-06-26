import 'components.dart';

final class ResponseObject extends ComponentValue {
  
  final String description;
  final Map<String, HeaderObject> headers;
  final List<MediaObject> content;

  ResponseObject({
    required this.description,
    this.headers = const {},
    this.content = const [],
  });
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'headers': headers.map((key, value) => MapEntry(key, value.toJson()..remove('name'))),
      'content': {for (var e in content) ...e.toJson()}
    };
  }

}