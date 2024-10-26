import '../entities/entities.dart';

class MyUser {
  String? userId;
  String? name;
  String? toPlace; // New field
  String? idcode;   // New field
  String? address; // New field

  MyUser({
     this.userId,
     this.name,
     this.toPlace,
     this.idcode,
     this.address,
  });

  static final empty = MyUser(
    userId: '', 
    name: '',
    toPlace: '', // Initialize new field
    idcode: '',   // Initialize new field
    address: '', // Initialize new field
  );

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId, 
      name: name, 
      toPlace: toPlace, // New field
      idcode: idcode,     // New field
      address: address,  // New field
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId, 
      name: entity.name, 
      toPlace: entity.toPlace, // New field
      idcode: entity.idcode,     // New field
      address: entity.address,  // New field
    );
  }

  @override
  String toString() {
    return 'MyUser: $userId, $name, $toPlace, $idcode, $address';
  }
}
