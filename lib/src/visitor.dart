import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:sqflite_orm/sqflite_orm.dart';
import 'package:sqflite_orm_generator/src/extensions.dart';

class FieldMetadata {
  final FieldType type;
  final bool primaryKey;
  final bool autoincrement;

  FieldMetadata({
    required this.type,
    this.primaryKey = false,
    this.autoincrement = false,
  });
}

class FieldsVisitor extends SimpleElementVisitor<void> {
  Map<String, FieldMetadata> fields = {};

  static Set<String> get acceptabledAnnotations => {
        typeToString<Ignore>(),
        typeToString<Column>(),
      };

  @override
  void visitFieldElement(FieldElement element) {
    String elementType = element.type.toString();
    final fieldAnnotations = element.metadata.where((annotation) =>
        annotation.element?.kind == ElementKind.CONSTRUCTOR &&
        acceptabledAnnotations.contains(annotation.element?.displayName));

    //if applyed ignore annotation just skip it
    if (fieldAnnotations.any((annotation) =>
        annotation.element?.displayName == typeToString<Ignore>())) {
      return;
    }

    //determine is it primary key or autoincrement
    final columnAnnotations = fieldAnnotations.where((annotation) =>
        annotation.element?.displayName == typeToString<Column>());
    if (columnAnnotations.length > 1) {
      print(
          'Found more than one @Column annotation, first annotation will be applied!');
    }
    final column = columnAnnotations.firstOrNull?.computeConstantValue();
    final isPrimaryKey = column?.getField('primaryKey')?.toBoolValue() ?? false;
    final isAutoincrement =
        column?.getField('autoincrement')?.toBoolValue() ?? false;
    final columnName =
        column?.getField('name')?.toStringValue() ?? element.name;

    //get field type
    final sqliteType = switch (elementType) {
      'int' => FieldType.integer,
      'String' => FieldType.text,
      'double' => FieldType.real,
      _ => FieldType.blob,
    };

    final canApplyAutoincrement =
        isAutoincrement && isPrimaryKey && sqliteType == FieldType.integer;
    if (!canApplyAutoincrement && isAutoincrement) {
      throw "'AUTOINCREMENT' keyword only can be applied for INTEGER columns with 'PRIMARY KEY' keyword";
    }

    if (fields.containsKey(columnName)) {
      throw 'The table already contains column with name [$columnName]';
    }

    fields[columnName] = FieldMetadata(
      type: sqliteType,
      primaryKey: isPrimaryKey,
      autoincrement: canApplyAutoincrement,
    );
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
