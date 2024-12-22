import '../entities/entities.dart';
import 'models.dart';

class Pizza {
  String? id;
  List<String>? pictures; // Danh sách đường dẫn ảnh
  String? name;
  String? location;
  String? floor;
  String? room;
  String? row; // Dãy nhà
  String? unit;

  Pizza({
    this.id,
    this.pictures,
    this.name,
    this.location,
    this.floor,
    this.room,
    this.row,
    this.unit,
  });

  PizzaEntity toEntity() {
    return PizzaEntity(
      id: id,
      pictures: pictures?.join(','), // Chuyển danh sách ảnh thành chuỗi
      name: name,
      location: location,
      floor: floor,
      room: room,
      row: row,
      unit: unit,
    );
  }

  static Pizza fromEntity(PizzaEntity entity) {
    return Pizza(
      id: entity.id,
      pictures: entity.pictures?.split(','), // Tách chuỗi thành danh sách
      name: entity.name,
      location: entity.location,
      floor: entity.floor,
      room: entity.room,
      row: entity.row,
      unit: entity.unit,
    );
  }
}

