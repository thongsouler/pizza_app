import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/views/add_edit_places_screen.dart';

class PlacesManagementScreen extends StatefulWidget {
  @override
  _PlacesManagementScreenState createState() => _PlacesManagementScreenState();
}

class _PlacesManagementScreenState extends State<PlacesManagementScreen> {
  String? _filterType = 'class'; // Default filter type
  final List<String> _placeTypes = ['class', 'work']; // Options for filter
  late final SignInBloc manager;

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('Quản lý địa điểm',  style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _filterType,
                  items: _placeTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(type == 'class'
                            ? 'Khu vực lớp học'
                            : 'Khu làm việc'),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterType = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add new place action
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: manager,
                              ),
                            ],
                            child: AddEditPlaceScreen(),
                          );
                        },
                      ),
                    );
                  },
                  child: const Text('Thêm mới'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('places')
                    .where('location', isEqualTo: _filterType)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Không có dữ liệu.'));
                  }

                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return _buildPlaceRow(place);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceRow(DocumentSnapshot place) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                place['name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.green),
            onPressed: () {
              // Edit action
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: manager,
                        ),
                      ],
                      child: AddEditPlaceScreen(
                        placeId: place.id,
                      ),
                    );
                  },
                ),
              );
            },
            child: const Text(
              'Sửa',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.red),
            onPressed: () {
              // Delete action
              _confirmDeletePlace(place.id);
            },
            child: const Text(
              'Xoá',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

// Show confirmation dialog before deleting
  void _confirmDeletePlace(String placeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xoá'),
          content: const Text('Bạn có chắc chắn muốn xoá địa điểm này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Hủy bỏ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deletePlace(placeId); // Proceed with deletion
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  // Delete place from Firestore
  void _deletePlace(String placeId) async {
    await FirebaseFirestore.instance.collection('places').doc(placeId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá địa điểm thành công.')),
    );
  }
}
