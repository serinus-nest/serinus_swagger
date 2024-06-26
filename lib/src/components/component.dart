class Component<T extends ComponentValue> {

  final String name;
  final T? value;

  Component({
    required this.name,
    required this.value,
  }) {
    if(value == null) throw Exception('Component value cannot be null');
  }

  Map<String, dynamic> toJson(){
    return {
      name: value
    };
  }

}

abstract class ComponentValue {

  Map<String, dynamic> toJson();

}