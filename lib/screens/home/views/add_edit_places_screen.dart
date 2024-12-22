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
  List<String> _imageUrls = []; // Danh sách đường dẫn ảnh
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
    try {
      final doc = await FirebaseFirestore.instance
          .collection('places_data')
          .doc(widget.placeId)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          _floorController.text = data['floor'] ?? '';
          _roomController.text = data['room'] ?? '';
          _imageUrls = (data['pictures'] as String?)?.split(',') ?? [];
          _selectedPlaceType = data['location'] ?? null;
          _rowController.text = data['row'] ?? 'A';
        });
      }
    } catch (e) {
      print('Error loading place data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(); // Chọn nhiều ảnh
      if (pickedFiles != null) {
        for (var pickedFile in pickedFiles) {
          final file = File(pickedFile.path);
          final storageRef =
              FirebaseStorage.instance.ref().child('places/${_uuid.v4()}.jpg');
          final uploadTask = await storageRef.putFile(file);
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          setState(() {
            _imageUrls.add(downloadUrl); // Thêm URL vào danh sách
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      if (_imageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ít nhất một ảnh')),
        );
        return;
      }

      final data = {
        'id': widget.placeId ?? _uuid.v4(),
        'name': _nameController.text,
        'floor': _floorController.text,
        'room': _roomController.text,
        'row': _rowController.text,
        'pictures': _imageUrls.join(','), // Chuyển danh sách thành chuỗi
        'location': _selectedPlaceType,
      };

      try {
        if (widget.placeId == null) {
          await FirebaseFirestore.instance.collection('places_data').add(data);
        } else {
          await FirebaseFirestore.instance
              .collection('places_data')
              .doc(widget.placeId)
              .update(data);
        }
        Navigator.of(context).pop();
      } catch (e) {
        print('Error saving place: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        title: Text(
          widget.placeId != null ? 'Sửa địa điểm' : 'Thêm địa điểm',
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _imageUrls.isNotEmpty
                          ? 'Danh sách ảnh đã chọn'
                          : 'Chưa chọn ảnh',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Chọn ảnh',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_imageUrls.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(3, 3),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Image.asset(
                                    'assets/building.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                      child: const Center(
                        child: Text('Xác nhận', style: TextStyle(fontSize: 20)),
                      ),
                    ),
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
