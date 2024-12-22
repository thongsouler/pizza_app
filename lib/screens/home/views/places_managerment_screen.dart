import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/views/add_edit_places_screen.dart';
import 'package:pizza_app/screens/home/views/place_types_manage_screen.dart';

class PlacesManagementScreen extends StatefulWidget {
  @override
  _PlacesManagementScreenState createState() => _PlacesManagementScreenState();
}

class _PlacesManagementScreenState extends State<PlacesManagementScreen> {
  String? _filterType;
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
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Quản lý địa điểm',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown for filtering places by type
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('place_types')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final placeTypes = snapshot.data!.docs;

                    if (placeTypes.isEmpty) {
                      return const Text('Không có loại địa điểm.');
                    }

                    // Tạo danh sách các DropdownMenuItem
                    final dropdownItems = [
                      const DropdownMenuItem<String>(
                        value: null, // Giá trị null cho "Tất cả địa điểm"
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Tất cả địa điểm',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      ...placeTypes
                          .map((type) {
                            final data = type.data() as Map<String, dynamic>;
                            if (data.containsKey('name')) {
                              final String typeName = type['name'];
                              return DropdownMenuItem(
                                value: typeName,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    typeName,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            }
                            return null; // Bỏ qua nếu không có trường "name"
                          })
                          .whereType<DropdownMenuItem<String>>()
                          .toList(),
                    ];

                    return DropdownButton<String>(
                      value:
                          _filterType, // Nếu _filterType là null, hiển thị "Tất cả địa điểm"
                      items: dropdownItems,
                      onChanged: (value) {
                        setState(() {
                          _filterType = value;
                        });
                      },
                    );
                  },
                ),

                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 55, 190, 252)),
                      onPressed: () {
                        // Navigate to manage place types
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PlaceTypesManagementScreen()),
                        );
                      },
                      child: SizedBox(
                        width: 120,
                        child: const Text('Quản lý Khu vực',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 55, 190, 252)),
                      onPressed: () {
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
                      child: SizedBox(
                        width: 120,
                        child: const Text(
                          'Thêm địa điểm',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('places_data')
                    .where('location', isEqualTo: _filterType)
                    .orderBy('name')
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
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 55, 190, 252)),
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
              style: TextStyle(color: Colors.white, fontSize: 16),
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
              style: TextStyle(color: Colors.white, fontSize: 16),
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
    await FirebaseFirestore.instance
        .collection('places_data')
        .doc(placeId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xoá địa điểm thành công.')),
    );
  }
}
