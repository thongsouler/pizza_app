import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pizza_app/restart_widget.dart';
import 'package:pizza_app/globals.dart' as globals;

class SchoolInfoScreen extends StatefulWidget {
  @override
  _SchoolInfoScreenState createState() => _SchoolInfoScreenState();
}

class _SchoolInfoScreenState extends State<SchoolInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _coverImage;
  bool _isEditing = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchSchoolInfo();
  }

  Future<void> _fetchSchoolInfo() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('place_info')
          .doc('basic_info')
          .get();

      if (snapshot.exists) {
        setState(() {
          _nameController.text = snapshot.data()?['name'] ?? '';
          _coverImage = snapshot.data()?['coverImage'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching school info: $e');
    }
  }

  Future<void> _updateSchoolInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection('place_info')
          .doc('basic_info')
          .update({
        'name': _nameController.text,
        'coverImage': _coverImage,
      }).then((value) {
        setState(() {
          _isEditing = false;
          globals.schoolName = _nameController.text;
          globals.schoolCoverImage = _coverImage ?? '';
        });
        Future.delayed(Duration(milliseconds: 300), () {
          RestartWidget.restartApp(context);
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
    } catch (e) {
      print('Error updating school info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi cập nhật thông tin')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Create a unique file name using timestamp
        final String uniqueFileName =
            'coverImage_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload the image to Firebase Storage
        final ref = FirebaseStorage.instance
            .ref()
            .child('school_images')
            .child(uniqueFileName);
        await ref.putFile(File(image.path));

        // Get the download URL
        final imageUrl = await ref.getDownloadURL();

        setState(() {
          _coverImage = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chọn ảnh thành công')),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi chọn ảnh')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Thay đổi thông tin',
          style: const TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // School Cover Image
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: _coverImage != null && _coverImage!.isNotEmpty
                  ? Image.network(
                      _coverImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image,
                          size: 100, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16.0),

            // School Name
            TextField(
              controller: _nameController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Save Button
            if (_isEditing)
              Center(
                child: ElevatedButton(
                  onPressed: _updateSchoolInfo,
                  child: const Text('Lưu thông tin'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
