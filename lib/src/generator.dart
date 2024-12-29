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

      if (column.primaryKey) scriptBuffer.write(' PRIMARY KEY');
      if (column.autoincrement) scriptBuffer.write(' AUTOINCREMENT');
      if (!column.acceptsNull && !column.primaryKey) {
        scriptBuffer.write(' NOT NULL');
      }

      scriptBuffer.writeln(columns.keys.last != columnName ? ',' : '');
    }

    scriptBuffer.writeln(');');
    return scriptBuffer.toString();
  }
}
