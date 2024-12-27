library sqflite_orm_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_orm_generator/src/generator.dart';

Builder generateData(BuilderOptions options) {
  return SharedPartBuilder(
    [SqfliteOrmGenerator()],
    'sqflite_orm',
  );
}
