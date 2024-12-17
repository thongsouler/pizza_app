import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/places/get_place_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:text_mask/text_mask.dart';
import 'home_screen.dart';

class AttendanceButton extends StatefulWidget {
  const AttendanceButton({Key? key}) : super(key: key);

  @override
  State<AttendanceButton> createState() => _AttendanceButtonState();
}

class _AttendanceButtonState extends State<AttendanceButton> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController bornController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 60,
      child: TextButton(
        onPressed: () {
          _showAttendanceDialog(context);
        },
        style: TextButton.styleFrom(
          elevation: 3.0,
          shadowColor: Colors.black,
          backgroundColor:
              const Color.fromARGB(255, 55, 190, 252).withOpacity(0.9),
          foregroundColor: Colors.white,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            'Không có CCCD',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _showAttendanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext tcontext) {
        return StatefulBuilder(
          builder: (tcontext, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Họ và tên',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: addressController,
                                decoration: const InputDecoration(
                                  labelText: 'Địa chỉ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: bornController,
                                inputFormatters: [
                                  TextMask(pallet: '##/##/####')
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Ngày sinh',
                                  hintText: 'ngày/tháng/năm',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(tcontext).pop();
                            },
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              final String name = nameController.text;

                              if (name.isEmpty ||
                                  addressController.text.isEmpty ||
                                  bornController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Vui lòng nhập đầy đủ thông tin!'),
                                  ),
                                );
                              } else {
                                Navigator.of(tcontext).pop();
                                _processLogin();
                              }
                            },
                            child: const Text('Xác nhận'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _processLogin() async {
    var user = MyUser(
      idcode: '0',
      name: nameController.text,
      address: addressController.text,
    );
    context.read<SignInBloc>().add(SignInRequired(user));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SignInBloc(
                    context.read<AuthenticationBloc>().userRepository),
              ),
              BlocProvider(
                create: (context) =>
                    GetPizzaBloc(FirebasePizzaRepo())..add(GetPizza()),
              ),
            ],
            child: HomeScreen(userData: user),
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}
