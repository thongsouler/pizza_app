import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/components/custom_appbar.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/places/get_place_bloc.dart';

import 'package:pizza_app/screens/home/views/details_screen.dart';
import 'package:pizza_app/screens/home/views/history_places_screen.dart';
import 'package:pizza_app/screens/home/views/list_place_screen.dart';
import 'package:pizza_app/screens/home/views/places_managerment_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:pizza_app/globals.dart' as globals;

class HomeScreen extends StatefulWidget {
  final MyUser? userData;
  const HomeScreen({Key? key, this.userData}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = '';
  late final SignInBloc manager;

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: manager,
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(
          manager: manager,
          isPushLoginScreen: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: widget.userData?.name != 'admin',
                      child: Text(
                        'CHÀO MỪNG QUÝ KHÁCH TỚI VỚI ${globals.schoolName}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CHÀO ${widget.userData?.name == 'admin' ? 'ADMIN' : widget.userData?.name},'
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      widget.userData?.name == 'admin'
                          ? 'CHỌN CHỨC NĂNG QUẢN LÝ DÀNH CHO ADMIN:'
                          : 'VUI LÒNG LỰA CHỌN ĐỊA ĐIỂM MUỐN ĐẾN:',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              widget.userData?.name == 'admin'
                  ? _buildAdminOptions(context)
                  : _buildUserOptions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildOptionContainer(
          context,
          title: 'Lịch sử đăng nhập'.toUpperCase(),
          onTap: () {
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
                    child: PlacesScreen(),
                  );
                },
              ),
            );
          },
        ),
        _buildOptionContainer(
          context,
          title: 'Quản lý địa điểm'.toUpperCase(),
          onTap: () {
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
                    child: PlacesManagementScreen(),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionContainer(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blueAccent, // Màu nền
          borderRadius: BorderRadius.circular(12.0), // Góc bo tròn
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Bóng mờ
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserOptions(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('place_types').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(
            'Không có dữ liệu khu vực!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          );
        }

        final placeTypes = snapshot.data!.docs;

        return Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 100.0,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: placeTypes.length,
            itemBuilder: (context, index) {
              final name = placeTypes[index]['name'] as String;
              return _buildOptionContainer(
                context,
                title: name.toUpperCase(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: manager,
                            ),
                            BlocProvider(
                              create: (context) =>
                                  GetPizzaBloc(FirebasePizzaRepo())
                                    ..add(GetPizza()),
                            ),
                          ],
                          child: ListPlaceScreen(placeType: name),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
