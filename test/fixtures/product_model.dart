import 'package:sqflite_orm/sqflite_orm.dart';

@DBTable(name: 'product')
class ProductModel {
  final int id;
  @Column(constraint: ColumnConstraint.unique)
  final String? ean;

  ProductModel({
    required this.id,
    required this.ean,
  });
}
