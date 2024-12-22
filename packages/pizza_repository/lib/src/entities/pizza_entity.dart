import 'package:pizza_repository/src/entities/macros_entity.dart';

import '../models/models.dart';

class PizzaEntity {
  final String? id;
  final String? pictures; // Chuỗi các đường dẫn ảnh cách nhau bởi dấu phẩy
  final String? name;
  final String? location;
  final String? floor;
  final String? room;
  final String? row; // Dãy nhà
  final String? unit;

  PizzaEntity({
    this.id,
    this.pictures,
    this.name,
    this.location,
    this.floor,
    this.room,
    this.row,
    this.unit,
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'pictures': pictures,
      'name': name,
      'location': location,
      'floor': floor,
      'room': room,
      'row': row,
      'unit': unit,
    };
  }

  static PizzaEntity fromDocument(Map<String, dynamic> doc) {
    return PizzaEntity(
        id: doc['id'],
        pictures: doc['pictures'],
        name: doc['name'],
        location: doc['location'],
        floor: doc['floor'],
        room: doc['room'],
        row: doc['row'],
        unit: doc['unit']);
  }
}
