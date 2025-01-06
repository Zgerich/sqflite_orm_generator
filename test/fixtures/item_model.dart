import 'package:sqflite_orm/sqflite_orm.dart';

@DBTable(name: 'item')
class ItemModel {
  @Column(constraint: ColumnConstraint.autoIncrement)
  final String id;

  final String name;

  ItemModel({
    required this.id,
    required this.name,
  });
}
