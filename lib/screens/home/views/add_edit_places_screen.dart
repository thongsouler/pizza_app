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

  // Properties for selected area type and building row
  String _selectedPlaceType = 'class'; // Default to "Lớp học"
  String _selectedGrade = '6'; // Default to "6"

  @override
  void initState() {
    super.initState();
    if (widget.placeId != null) {
      _loadPlaceData();
    } else {
      // Tự động điền Tên địa điểm nếu khối đã chọn và loại khu vực là lớp học
      if (_selectedPlaceType == 'class') {
        _updatePlaceName();
      }
    }
  }

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
      _imageUrl = data['picture'];
      _selectedPlaceType = data['location'] ?? 'class';
      _rowController.text = data['row'] ?? 'A';
      _selectedGrade = data['unit'] ?? '6';
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

  void _updatePlaceName() {
    if (_selectedPlaceType == 'class') {
      _nameController.text = 'Lớp $_selectedGrade';
    } else {
      _nameController.clear();
    }
  }

  void _savePlace() async {
    if (_formKey.currentState!.validate()) {
      if (_imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ảnh')),
        );
        return;
      }

      final data = {
        'id': widget.placeId ?? _uuid.v4(),
        'name': _nameController.text,
        'floor': _floorController.text,
        'room': _roomController.text,
        'row': _rowController.text,
        'unit': _selectedGrade,
        'picture': _imageUrl,
        'location': _selectedPlaceType,
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
                // ChoiceChips for Khu vực selection
                const Text(
                  'Khu vực',
                  style: TextStyle(fontSize: 18),
                ),
                Wrap(
                  spacing: 10.0,
                  children: [
                    ChoiceChip(
                      selectedColor: const Color.fromARGB(255, 55, 190, 252),
                      backgroundColor: Colors.grey[200],
                      label: const Text('Lớp học'),
                      selected: _selectedPlaceType == 'class',
                      onSelected: (selected) {
                        setState(() {
                          _selectedPlaceType = 'class';
                          _updatePlaceName();
                        });
                      },
                    ),
                    ChoiceChip(
                      selectedColor: const Color.fromARGB(255, 55, 190, 252),
                      backgroundColor: Colors.grey[200],
                      label: const Text(
                        'Khu làm việc',
                        style: TextStyle(fontSize: 18),
                      ),
                      selected: _selectedPlaceType == 'work',
                      onSelected: (selected) {
                        setState(() {
                          _selectedPlaceType = 'work';
                          _updatePlaceName();
                        });
                      },
                    ),
                  ],
                ),

                // ChoiceChip for selecting Khối (6, 7, 8, 9)
                Visibility(
                  visible: _selectedPlaceType == 'class',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Khối',
                        style: TextStyle(fontSize: 18),
                      ),
                      Wrap(
                        spacing: 10.0,
                        children: ['6', '7', '8', '9'].map((grade) {
                          return ChoiceChip(
                            selectedColor:
                                const Color.fromARGB(255, 55, 190, 252),
                            backgroundColor: Colors.grey[200],
                            label: Text(grade),
                            selected: _selectedGrade == grade,
                            onSelected: (selected) {
                              setState(() {
                                _selectedGrade = grade;
                                _updatePlaceName();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // ChoiceChip for selecting Dãy nhà
                const SizedBox(height: 20),
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
                                'assets/haixuan.jpg',
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
