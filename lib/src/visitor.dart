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
    final columnName =
        column?.getField('name')?.toStringValue() ?? element.name;

    final constrainValue =
        column?.getField('constraint')?.getField('value')?.toIntValue();
    final constraint = constrainValue != null
        ? ColumnConstraint.fromValue(constrainValue)
        : null;

    final sqliteType = switch (element.type.getDisplayString()) {
      'int' || 'int?' => ColumnType.integer,
      'String' || 'String?' => ColumnType.text,
      'double' || 'double?' => ColumnType.real,
      _ => ColumnType.blob,
    };
    final acceptsNull =
        element.type.nullabilitySuffix == NullabilitySuffix.question;

    final canApplyAutoincrement =
        constraint == ColumnConstraint.autoIncrement &&
            sqliteType == ColumnType.integer &&
            !acceptsNull;

    if (!canApplyAutoincrement &&
        constraint == ColumnConstraint.autoIncrement) {
      throw "'AUTOINCREMENT' keyword only can be applied for INTEGER columns ";
    }

    if (acceptsNull && constraint == ColumnConstraint.primaryKey) {
      throw "'PRIMARY KEY' keyword can't be applied to nullable column";
    }

    tableColumns[columnName] = ColumnMetadata(
      type: sqliteType,
      acceptsNull: acceptsNull,
      constraint: constraint,
    );
    super.visitFieldElement(element);
  }
}

class ColumnMetadata {
  final ColumnType type;
  final bool acceptsNull;
  final ColumnConstraint? constraint;

  ColumnMetadata({
    required this.type,
    required this.acceptsNull,
    this.constraint,
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
