class MyUserEntity {
  String? userId;
  String? name;
  String? toPlace; // New field
  String? idcode;   // New field
  String? address; // New field

  MyUserEntity({
     this.userId,
     this.name,
     this.toPlace, // New field
     this.idcode,   // New field
     this.address,  // New field
  });

  Map<String, Object?> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'toPlace': toPlace,   // New field
      'idcode': idcode,       // New field
      'address': address,    // New field
    };
  }

  static MyUserEntity fromDocument(Map<String?, dynamic> doc) {
    return MyUserEntity(
      userId: doc['userId'], 
      name: doc['name'], 
      toPlace: doc['toPlace'], // New field
      idcode: doc['idcode'],     // New field
      address: doc['address'],  // New field
    );
  }
}
