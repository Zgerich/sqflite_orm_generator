// ignore_for_file: unused_field

import 'package:sqflite_orm/sqflite_orm.dart';

@DBTable(name: 'test')
class TestModel {
  @Column(constraint: ColumnConstraint.autoIncrement)
  final int? id;

  @Ignore()
  final String title;

  String _privateField = 'test';

  static String staticField = 'test';

  String get getter => _privateField;
  set setter(String newValue) => _privateField = newValue;

  TestModel({required this.id, required this.title});
}
