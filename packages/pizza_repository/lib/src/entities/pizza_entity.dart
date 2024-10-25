import 'package:pizza_repository/src/entities/macros_entity.dart';

import '../models/models.dart';

class PizzaEntity {
  String? id;
  String? picture;
  String? name;
  String? location;
  String? floor;
  String? room;
  String? row; //Dãy nhà
  String? unit;

  PizzaEntity({
    this.id,
    this.picture,
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
      'picture': picture,
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
      picture: doc['picture'],
      name: doc['name'],
      location: doc['location'],
      floor: doc['floor'],
      room: doc['room'],
      row: doc['row'],
      unit: doc['unit']
    );
  }
}
