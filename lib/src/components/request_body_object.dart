import 'components.dart';

final class RequestBody extends ComponentValue {

  final String name;
  final Map<String, MediaObject> value;
  final bool required;

  RequestBody({
    required this.name,
    required this.value,
    this.required = false,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      name: value.map((key, value) => MapEntry(key, value.toJson())),
      'required': required,
    };
  }

}