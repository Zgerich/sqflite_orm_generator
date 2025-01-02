import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_orm/sqflite_orm.dart';
import 'package:sqflite_orm_generator/src/visitor.dart';

class SqfliteOrmGenerator extends GeneratorForAnnotation<DBTable> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final tableNameReader = annotation.read('name');
    final className = element.displayName;
    final tableName =
        tableNameReader.isString ? tableNameReader.stringValue : className;

    final buffer = StringBuffer()
      ..writeln(
          '// This file contains code of SQL queries for table $tableName')
      ..writeln();

    final FieldsVisitor visitor = FieldsVisitor();
    element.visitChildren(visitor);

    final createScript =
        _generateCreateTableScript(visitor.tableColumns, tableName);
    buffer.writeln("String _\$CreateQuery() => '''$createScript''';");
    buffer.writeln();

    final toMapMethod = _generateToMapMethod(visitor.tableColumns, className);
    buffer.writeln(toMapMethod);
    buffer.writeln();

    final fromMapMethod =
        _generateFromMapMethod(visitor.tableColumns, className);
    buffer.writeln(fromMapMethod);
    buffer.writeln();

    buffer.toString();
    return buffer.toString();
  }

  String _generateCreateTableScript(
      Map<String, ColumnMetadata> columns, String tableName) {
    final scriptBuffer = StringBuffer()
      ..writeln()
      ..writeln('CREATE TABLE IF NOT EXISTS [$tableName] (');

    for (final columnName in columns.keys) {
      final column = columns[columnName]!;

      scriptBuffer.write(' [$columnName] ${column.type}');

      switch (column.constraint) {
        case ColumnConstraint.autoIncrement:
          scriptBuffer.write(' PRIMARY KEY AUTOINCREMENT');
        case ColumnConstraint.primaryKey:
          scriptBuffer.write(' PRIMARY KEY');
        case ColumnConstraint.unique:
          scriptBuffer.write(' UNIQUE');
        default:
      }

      if (!column.acceptsNull &&
          column.constraint != ColumnConstraint.autoIncrement &&
          column.constraint != ColumnConstraint.primaryKey) {
        scriptBuffer.write(' NOT NULL');
      }

      scriptBuffer.writeln(columns.keys.last != columnName ? ',' : '');
    }

    scriptBuffer.writeln(');');
    return scriptBuffer.toString();
  }

  String _generateToMapMethod(
    Map<String, ColumnMetadata> columns,
    String className,
  ) {
    final buffer = StringBuffer();

    buffer.writeln(
        'Map<String, dynamic> _\$${className}ToMap($className obj) => {');
    for (final columnName in columns.keys) {
      buffer.writeln("'$columnName' : obj.${columns[columnName]!.fieldName},");
    }
    buffer.writeln('};');

    return buffer.toString();
  }

  String _generateFromMapMethod(
      Map<String, ColumnMetadata> columns, String className) {
    final buffer = StringBuffer();

    buffer.writeln(
        '$className _\$${className}FromMap(Map<String, dynamic> map) => $className(');
    for (final columnName in columns.keys) {
      buffer.writeln("${columns[columnName]!.fieldName} : map['$columnName'],");
    }
    buffer.writeln(');');

    return buffer.toString();
  }
}
