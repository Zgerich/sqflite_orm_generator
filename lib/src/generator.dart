import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_orm/sqflite_orm.dart';
import 'package:sqflite_orm_generator/src/extensions.dart';
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
      ..writeln()
      ..writeln('extension ${tableName.capitalize()}Extension on $className {');

    final FieldsVisitor visitor = FieldsVisitor();
    element.visitChildren(visitor);

    final createScript = _generateCreateTableScript(visitor.fields, tableName);
    buffer.writeln("String get createScript => '''$createScript''';");

    buffer.writeln('}');
    buffer.toString();
    return buffer.toString();
  }

  String _generateCreateTableScript(
      List<FieldMetadata> fields, String tableName) {
    final scriptBuffer = StringBuffer()
      ..writeln()
      ..writeln('CREATE TABLE IF NOT EXISTS [$tableName] (');

    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      scriptBuffer.write(' [${field.name}] ${field.type}');

      scriptBuffer.writeln(i != fields.length - 1 ? ',' : '');
    }

    scriptBuffer.writeln(');');
    return scriptBuffer.toString();
  }
}
