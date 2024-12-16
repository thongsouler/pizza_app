import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class AddEditPlaceScreen extends StatefulWidget {
  final String? placeId;

  const AddEditPlaceScreen({Key? key, this.placeId}) : super(key: key);

  @override
  _AddEditPlaceScreenState createState() => _AddEditPlaceScreenState();
}

class _AddEditPlaceScreenState extends State<AddEditPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _rowController = TextEditingController();
  String? _imageUrl;
  final _uuid = Uuid();

  // Selected place type
  String? _selectedPlaceType; // Default is null
  List<String> _placeTypes = []; // Store place types from Firestore

  @override
  void initState() {
    super.initState();
    if (widget.placeId != null) {
      _loadPlaceData();
    }
    _fetchPlaceTypes(); // Fetch place types on init
  }

  Future<void> _fetchPlaceTypes() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('place_types').get();
      setState(() {
        _placeTypes =
            querySnapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching place types: $e');
    }
  }

  void _loadPlaceData() async {
    final doc = await FirebaseFirestore.instance
        .collection('places_data')
        .doc(widget.placeId)
        .get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _floorController.text = data['floor'] ?? '';
      _roomController.text = data['room'] ?? '';
      _imageUrl = data['picture'];
      _selectedPlaceType = data['location'] ?? 'class';
      _rowController.text = data['row'] ?? 'A';
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('places/${widget.placeId ?? DateTime.now().toString()}.jpg');
      final uploadTask = await storageRef.putFile(file);
      _imageUrl = await uploadTask.ref.getDownloadURL();
      setState(() {});
    }
  }

  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      // if (_imageUrl == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Vui lòng chọn ảnh')),
      //   );
      //   return;
      // }

      final data = {
        'id': widget.placeId ?? _uuid.v4(),
        'name': _nameController.text,
        'floor': _floorController.text,
        'room': _roomController.text,
        'row': _rowController.text,
        'picture': _imageUrl,
        'location': _selectedPlaceType,
      };

      if (widget.placeId == null) {
        await FirebaseFirestore.instance.collection('places_data').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('places_data')
            .doc(widget.placeId)
            .update(data);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        title: Text(
          widget.placeId != null ? 'Chỉnh sửa địa điểm' : 'Thêm mới địa điểm',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khu vực',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Chọn khu vực',
                  ),
                  value: _selectedPlaceType,
                  items: _placeTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlaceType = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Vui lòng chọn khu vực' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rowController,
                  decoration: const InputDecoration(
                      labelText: 'Dãy nhà',
                      labelStyle: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _floorController,
                  decoration: const InputDecoration(
                      labelText: 'Tầng', labelStyle: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(
                      labelText: 'Phòng', labelStyle: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Tên địa điểm',
                      labelStyle: TextStyle(fontSize: 18)),
                  validator: (value) =>
                      value!.isEmpty ? 'Nhập tên địa điểm' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_imageUrl != null ? 'Ảnh đã chọn' : 'Chưa chọn ảnh',
                        style: TextStyle(fontSize: 18)),
                    Visibility(
                      visible: _imageUrl != null,
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(3, 3),
                                blurRadius: 5),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            _imageUrl ?? '',
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/building.png',
                                fit: BoxFit.fitHeight,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Chọn ảnh',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      elevation: 3.0,
                      shadowColor: Colors.black,
                      backgroundColor: const Color.fromARGB(255, 55, 190, 252)
                          .withOpacity(0.9),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _savePlace,
                    child: SizedBox(
                        width: 200,
                        height: 60,
                        child: Center(
                            child: const Text('Xác nhận',
                                style: TextStyle(fontSize: 20)))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
