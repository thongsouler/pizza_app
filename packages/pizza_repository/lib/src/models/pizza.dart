import '../entities/entities.dart';
import 'models.dart';

class Pizza {
  String id;
  String picture;
  String name;
  String description;
  String location;

  Pizza({
    required this.id,
    required this.picture,
    required this.name,
    required this.description,
    required this.location,
  });

  PizzaEntity toEntity() {
    return PizzaEntity(
      id: id,
      picture: picture,
      name: name,
      description: description,
      location: location,
    );
  }

  static Pizza fromEntity(PizzaEntity entity) {
    return Pizza(
      id: entity.id,
      picture: entity.picture,
      name: entity.name,
      description: entity.description,
      location: entity.location
    );
  }
}