class DocumentSpecification {

  final String title;
  final String version;
  final String description;

  DocumentSpecification({
    required this.title,
    this.version = '1.0',
    this.description = '',
  });

}