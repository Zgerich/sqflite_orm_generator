import 'package:sqflite_orm/sqflite_orm.dart';

@DBTable(name: 'user')
class UserModel {
  @Column(constraint: ColumnConstraint.autoIncrement)
  final int id;

  final String name;

  @Column(name: 'name')
  final String aliasName;

  UserModel({
    required this.id,
    required this.name,
    required this.aliasName,
  });
}
