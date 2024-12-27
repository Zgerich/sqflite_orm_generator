import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';

typedef FieldMetadata = ({String name, FieldType type});

class FieldsVisitor extends SimpleElementVisitor<void> {
  List<FieldMetadata> fields = [];

  @override
  void visitFieldElement(FieldElement element) {
    String elementType = element.type.toString();
    final fieldAnnotations = element.metadata;

    if (fieldAnnotations.any((annotation) =>
        annotation.element?.displayName == 'Ignore' &&
        annotation.element?.kind == ElementKind.CONSTRUCTOR)) {
      return;
    }
    final sqliteType = switch (elementType) {
      'int' => FieldType.integer,
      'String' => FieldType.text,
      'double' => FieldType.real,
      _ => FieldType.blob,
    };
    fields.add((name: element.name, type: sqliteType));
    super.visitFieldElement(element);
  }
}

enum FieldType {
  integer,
  text,
  real,
  blob;

  @override
  String toString() => switch (this) {
        integer => 'INTEGER',
        text => 'TEXT',
        real => 'REAL',
        blob => 'BLOB',
      };
}
