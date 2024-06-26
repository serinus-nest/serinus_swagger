import '../api_spec.dart';
import 'parameter_object.dart';

class HeaderObject extends ParameterObject {

  HeaderObject({
    super.description,
    super.schema,
    super.required,
    super.deprecated
  }) : super(
    name: '',
    in_: SpecParameterType.header,
  );

  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..remove('name')..remove('in');
  }

}