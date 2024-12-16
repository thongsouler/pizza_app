import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceTypesManagementScreen extends StatefulWidget {
  @override
  _PlaceTypesManagementScreenState createState() =>
      _PlaceTypesManagementScreenState();
}

class _PlaceTypesManagementScreenState
    extends State<PlaceTypesManagementScreen> {
  final TextEditingController _nameController = TextEditingController();

  // Hiển thị dialog thêm hoặc sửa
  void _showEditDialog({String? typeId, String? existingName}) {
    _nameController.text = existingName ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(typeId == null ? 'Thêm Loại' : 'Sửa Loại'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Tên Loại',
            hintText: 'Nhập tên loại (vd: class, work)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (typeId == null) {
                _addPlaceType(_nameController.text.trim());
              } else {
                _editPlaceType(typeId, _nameController.text.trim());
              }
              Navigator.of(context).pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // Thêm loại mới
  Future<void> _addPlaceType(String name) async {
    if (name.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('place_types')
        .add({'name': name});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm loại thành công.')),
    );
  }

  // Sửa loại
  Future<void> _editPlaceType(String typeId, String newName) async {
    if (newName.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('place_types')
        .doc(typeId)
        .update({'name': newName});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã cập nhật loại thành công.')),
    );
  }

  // Xóa loại
  Future<void> _deletePlaceType(String typeId) async {
    await FirebaseFirestore.instance
        .collection('place_types')
        .doc(typeId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá loại thành công.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        title: const Text(
          'Quản lý loại địa điểm',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('place_types').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Không có dữ liệu.'));
          }

          final placeTypes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: placeTypes.length,
            itemBuilder: (context, index) {
              final placeType = placeTypes[index];
              return ListTile(
                title: Text(
                  placeType['name'] ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(
                        typeId: placeType.id,
                        existingName: placeType['name'],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteType(placeType.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _confirmDeleteType(String typeId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá'),
        content: const Text('Bạn có chắc chắn muốn xoá loại này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deletePlaceType(typeId);
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}
