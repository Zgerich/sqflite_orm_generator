import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_orm_generator/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('Generator test', () {
    final builder = SharedPartBuilder([SqfliteOrmGenerator()], 'sqflite_orm');
    final inputId = AssetId('a', 'lib/example.dart');
    final outputId = AssetId('a', 'lib/example.sqflite_orm.g.part');
    final inputCode = File('test/fixtures/test_model.dart').readAsStringSync();
    final writer = InMemoryAssetWriter();
    test("'AUTOINCREMENT' is applied to a nullable field", () async {
      await testBuilder(
        builder,
        {inputId.toString(): inputCode},
        reader: await PackageAssetReader.currentIsolate(),
        writer: writer,
      );
      final generatedBytes = writer.assets[outputId];

      final generatedContent = utf8.decode(generatedBytes!);

      expect(
        generatedContent,
        contains('[id] INTEGER PRIMARY KEY AUTOINCREMENT'),
      );
    });

    test(
        "Do not generate code for getters, setters, static, const and private fields",
        () async {
      await testBuilder(
        builder,
        {inputId.toString(): inputCode},
        reader: await PackageAssetReader.currentIsolate(),
        writer: writer,
      );
      final generatedBytes = writer.assets[outputId];

      final generatedContent = utf8.decode(generatedBytes!);

      expect(
        generatedContent,
        isNot(contains('[staticField]')),
        reason: 'The code was generated for static field',
      );

      expect(
        generatedContent,
        isNot(contains('[getter]')),
        reason: 'The code was generated for getter',
      );

      expect(
        generatedContent,
        isNot(contains('[setter]')),
        reason: 'The code was generated for setter',
      );

      expect(
        generatedContent,
        isNot(contains('[_privateField]')),
        reason: 'The code was generated for private field',
      );
    });
  });
}
