import 'dart:io';

import 'package:build_test/build_test.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_orm_generator/src/generator.dart';
import 'package:test/test.dart';

void main() {
  group('Generator exceptions test', () {
    final builder = SharedPartBuilder([SqfliteOrmGenerator()], 'sqflite_orm');
    final inputId = AssetId('a', 'lib/example.dart');
    test("'AUTOINCREMENT' is applied to a non-integer field", () async {
      final inputCode =
          File('test/fixtures/item_model.dart').readAsStringSync();

      await expectLater(
        testBuilder(
          builder,
          {inputId.toString(): inputCode},
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          predicate((e) => e is InvalidGenerationSource),
        ),
      );
    });

    test('There are duplicate SQLite column names', () async {
      final inputCode =
          File('test/fixtures/user_model.dart').readAsStringSync();

      await expectLater(
        testBuilder(
          builder,
          {inputId.toString(): inputCode},
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          predicate((e) => e is InvalidGenerationSource),
        ),
      );
    });

    test("'UNIQUE' keyword is applied to a nullable field", () async {
      final inputCode =
          File('test/fixtures/product_model.dart').readAsStringSync();

      await expectLater(
        testBuilder(
          builder,
          {inputId.toString(): inputCode},
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          predicate((e) => e is InvalidGenerationSource),
        ),
      );
    });

    test("'PRIMARY KEY' is applied to a nullable field.", () async {
      final inputCode =
          File('test/fixtures/vehicle_model.dart').readAsStringSync();

      await expectLater(
        testBuilder(
          builder,
          {inputId.toString(): inputCode},
          reader: await PackageAssetReader.currentIsolate(),
        ),
        throwsA(
          predicate((e) => e is InvalidGenerationSource),
        ),
      );
    });
  });
}
