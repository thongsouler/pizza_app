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
  final TextEditingController _unitController = TextEditingController();
  String? _placeType;
  String? _imageUrl;
  String? _location;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.placeId != null) {
      _loadPlaceData();
    }
  }

  // Load place data for editing
  void _loadPlaceData() async {
    final doc = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .get();
    final data = doc.data();
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _floorController.text = data['floor'] ?? '';
      _roomController.text = data['room'] ?? '';
      _rowController.text = data['row'] ?? '';
      _unitController.text = data['unit'] ?? '';
      _imageUrl = data['picture'];
      _placeType = data['placeType'];
      _location = data['location'];

      // Set _placeType based on location field
      if (_location == 'class') {
        _placeType = 'class';
      } else if (_location == 'work') {
        _placeType = 'work';
      }
      setState(() {});
    }
  }

  // Image picker and Firebase storage upload
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

  // Save place data to Firestore
  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'id': widget.placeId ?? _uuid.v4(),
        'name': _nameController.text,
        'location': _location,
        'floor': _floorController.text,
        'room': _roomController.text,
        'row': _rowController.text,
        'unit': _unitController.text,
        'picture': _imageUrl,
        'placeType': _placeType,
      };

      if (widget.placeId == null) {
        await FirebaseFirestore.instance.collection('places').add(data);
      } else {
        await FirebaseFirestore.instance
            .collection('places')
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
        backgroundColor: Colors.lightGreen,
        title: Text(widget.placeId != null
            ? 'Chỉnh sửa địa điểm'
            : 'Thêm mới địa điểm'),
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
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên địa điểm'),
                  validator: (value) =>
                      value!.isEmpty ? 'Nhập tên địa điểm' : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _placeType,
                  decoration: const InputDecoration(labelText: 'Khu vực'),
                  items: ['class', 'work'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type == 'class' ? 'Lớp học' : 'Khu làm việc'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _placeType = value;
                      _location = value; // Automatically update location
                      if (value == 'work') {
                        _unitController.text =
                            ''; // Clear grade if placeType is work
                      }
                    });
                  },
                ),
                if (_placeType == 'class')
                  DropdownButtonFormField<String>(
                    value: _unitController.text,
                    decoration: const InputDecoration(labelText: 'Khối'),
                    items: ['6', '7', '8', '9'].map((grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text('Khối $grade'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _unitController.text = value!;
                      });
                    },
                  ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _rowController,
                  decoration: const InputDecoration(labelText: 'Dãy nhà'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _floorController,
                  decoration: const InputDecoration(labelText: 'Tầng'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _roomController,
                  decoration: const InputDecoration(labelText: 'Phòng'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_imageUrl != null ? 'Ảnh đã chọn' : 'Chưa chọn ảnh'),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Chọn ảnh'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _savePlace,
                    child: const Text('Xác nhận'),
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
