import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:sqflite_orm/sqflite_orm.dart';
import 'package:sqflite_orm_generator/src/extensions.dart';

class FieldsVisitor extends SimpleElementVisitor<void> {
  Map<String, ColumnMetadata> tableColumns = {};

  static Set<String> get acceptabledAnnotations => {
        typeToString<Ignore>(),
        typeToString<Column>(),
      };

  @override
  void visitFieldElement(FieldElement element) {
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

    final sqliteType = switch (element.type.getDisplayString()) {
      'int' => ColumnType.integer,
      'String' => ColumnType.text,
      'double' => ColumnType.real,
      _ => ColumnType.blob,
    };
    final acceptsNull =
        element.type.nullabilitySuffix == NullabilitySuffix.question;

    final canApplyAutoincrement = isAutoincrement &&
        isPrimaryKey &&
        sqliteType == ColumnType.integer &&
        !acceptsNull;

    if (!canApplyAutoincrement && isAutoincrement) {
      throw "'AUTOINCREMENT' keyword only can be applied for INTEGER columns with 'PRIMARY KEY' keyword";
    }

    if (tableColumns.containsKey(columnName)) {
      throw 'The table already contains column with name [$columnName]';
    }

    tableColumns[columnName] = ColumnMetadata(
      type: sqliteType,
      primaryKey: isPrimaryKey,
      autoincrement: canApplyAutoincrement,
      acceptsNull: acceptsNull,
    );
    super.visitFieldElement(element);
  }
}

class ColumnMetadata {
  final ColumnType type;
  final bool primaryKey;
  final bool autoincrement;
  final bool acceptsNull;

  ColumnMetadata({
    required this.type,
    required this.primaryKey,
    required this.autoincrement,
    required this.acceptsNull,
  });
}

enum ColumnType {
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
