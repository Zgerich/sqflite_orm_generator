import 'package:sqflite_orm/sqflite_orm.dart';

@DBTable(name: 'vehicle')
class VehicleModel {
  @Column(constraint: ColumnConstraint.primaryKey)
  final int? id;
  final String vin;

  VehicleModel({
    required this.id,
    required this.vin,
  });
}
