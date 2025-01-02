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
    if (element.isStatic) return;
    if (!element.isPublic) return;

    final fieldAnnotations = element.metadata.where((annotation) =>
        annotation.element?.kind == ElementKind.CONSTRUCTOR &&
        acceptabledAnnotations.contains(annotation.element?.displayName));
    final fieldName = element.name;

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
    final columnName = column?.getField('name')?.toStringValue() ?? fieldName;

    final constrainValue =
        column?.getField('constraint')?.getField('value')?.toIntValue();
    final constraint = constrainValue != null
        ? ColumnConstraint.fromValue(constrainValue)
        : null;

    final sqliteType = switch (element.type.getDisplayString()) {
      'int' || 'int?' => SQLiteType.integer,
      'String' || 'String?' => SQLiteType.text,
      'double' || 'double?' => SQLiteType.real,
      _ => SQLiteType.blob,
    };
    final acceptsNull =
        element.type.nullabilitySuffix == NullabilitySuffix.question;

    final canApplyAutoincrement =
        constraint == ColumnConstraint.autoIncrement &&
            sqliteType == SQLiteType.integer &&
            !acceptsNull;

    if (!canApplyAutoincrement &&
        constraint == ColumnConstraint.autoIncrement) {
      throw "'AUTOINCREMENT' keyword only can be applied for INTEGER columns ";
    }

    if (acceptsNull && constraint == ColumnConstraint.primaryKey) {
      throw "'PRIMARY KEY' keyword can't be applied to nullable column";
    }

    if (acceptsNull && constraint == ColumnConstraint.unique) {
      throw "'UNIQUE' keyword can't be applied to nullable column";
    }

    if (tableColumns[columnName] != null) {
      throw "Found duplicate column '$columnName'";
    }

    tableColumns[columnName] = ColumnMetadata(
      type: sqliteType,
      fieldName: fieldName,
      acceptsNull: acceptsNull,
      constraint: constraint,
    );
    super.visitFieldElement(element);
  }
}

class ColumnMetadata {
  final SQLiteType type;
  final String fieldName;
  final bool acceptsNull;
  final ColumnConstraint? constraint;

  ColumnMetadata({
    required this.type,
    required this.fieldName,
    required this.acceptsNull,
    this.constraint,
  });
}

enum SQLiteType {
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
