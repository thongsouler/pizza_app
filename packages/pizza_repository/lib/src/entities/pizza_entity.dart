import 'package:pizza_repository/src/entities/macros_entity.dart';

import '../models/models.dart';

class PizzaEntity {
  String id;
  String picture;
  String name;
  String description;
  String location; // Thêm trường mới

  PizzaEntity({
    required this.id,
    required this.picture,
    required this.name,
    required this.description,
    required this.location, // Thêm trường mới vào constructor
  });

  Map<String, Object?> toDocument() {
    return {
      'id': id,
      'picture': picture,
      'name': name,
      'description': description,
      'location': location, // Thêm trường mới vào document
    };
  }

  static PizzaEntity fromDocument(Map<String, dynamic> doc) {
    return PizzaEntity(
      id: doc['id'],
      picture: doc['picture'],
      name: doc['name'],
      description: doc['description'],
      location: doc['location'], // Thêm trường mới vào quá trình khôi phục từ document
    );
  }
}
