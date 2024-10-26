import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/components/custom_appbar.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';

import 'package:pizza_app/screens/home/views/details_screen.dart';
import 'package:pizza_app/screens/home/views/history_places_screen.dart';
import 'package:pizza_app/screens/home/views/list_place_screen.dart';
import 'package:pizza_app/screens/home/views/places_managerment_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Visibility(
                        visible: widget.userData?.name != 'admin',
                        child: const Text(
                          'CHÀO MỪNG QUÝ KHÁCH TỚI VỚI TRƯỜNG THCS HẢI XUÂN',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'CHÀO ${widget.userData?.name == 'admin' ? 'ADMIN' : widget.userData?.name},',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.userData?.name == 'admin'
                      ? [
                          _buildOptionContainer(
                            context,
                            title: 'Lịch sử đăng nhập'.toUpperCase(),
                            onTap: () {
                              // Navigate to the login history screen
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
                            title: 'Quản lý thông tin chỉ đường'.toUpperCase(),
                            onTap: () {
                              // Navigate to the directions management screen
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
                        ]
                      : [
                          _buildOptionContainer(
                            context,
                            title:
                                'Khu vực học tập\ncủa học sinh'.toUpperCase(),
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
                                      child: const ListPlaceScreen(
                                        placeType: 'class',
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          _buildOptionContainer(
                            context,
                            title: 'Khu vực làm việc\ncủa nhà trường'
                                .toUpperCase(),
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
                                      child: const ListPlaceScreen(
                                        placeType: 'work',
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionContainer(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
