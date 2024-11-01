import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/home/blocs/places/get_place_bloc.dart';
import 'package:pizza_app/screens/home/views/home_screen.dart';
import 'package:pizza_app/screens/home/views/qr_code_scanner.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:pizza_app/globals.dart' as globals;
import 'package:user_repository/user_repository.dart';
import '../../../components/my_text_field.dart';
import '../blocs/sing_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  String? _errorMsg;
  late final SignInBloc manager;

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignInBloc, SignInState>(
      listener: (context, state) {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child: TextButton(
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
                          BlocProvider(
                            create: (context) =>
                                GetPizzaBloc(FirebasePizzaRepo())
                                  ..add(GetPizza()),
                          ),
                        ],
                        child: QrScanScreen(),
                      );
                    },
                  ),
                );
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
                  'Quét QR CCCD',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chức năng đang phát triển!')),
                );

                globals.currentUser = MyUser(
                  userId: '88888',
                  name: 'admin',
                  idcode: '88888',
                  address: 'Hanoi',
                );
                context
                    .read<SignInBloc>()
                    .add(SignInRequired(globals.currentUser!));
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
                        child: const HomeScreen(),
                      );
                    },
                  ),
                );
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
                  'Điểm danh',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 60,
            child: TextButton(
              onPressed: () {
                _showAdminPasswordDialog();
              },
              style: TextButton.styleFrom(
                  shadowColor: Colors.black,
                  backgroundColor: Colors.white.withOpacity(0.4)),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Text(
                  'Đăng nhập Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAdminPasswordDialog() {
    final adminPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use a separate context for dialog
        return AlertDialog(
          title: const Text(
            'Nhập mật khẩu admin',
            style: TextStyle(fontSize: 20),
          ),
          content: TextField(
            controller: adminPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Nhập mật khẩu',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Hủy',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
            ),
            TextButton(
              child: const Text(
                'Xác nhận',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () {
                if (adminPasswordController.text == '888') {
                  Navigator.of(dialogContext).pop(); // Close dialog first
                  // Now navigate to the HomeScreen in the main context
                  _navigateToHomeScreen();
                } else {
                  // Show an error message if the password is incorrect
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mật khẩu không đúng')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToHomeScreen() {
    globals.currentUser = MyUser(
      userId: '88888',
      name: 'admin',
      idcode: '88888',
      address: 'Hanoi',
    );
    context.read<SignInBloc>().add(SignInRequired(globals.currentUser!));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => SignInBloc(
                  context.read<AuthenticationBloc>().userRepository,
                ),
              ),
              BlocProvider(
                create: (context) =>
                    GetPizzaBloc(FirebasePizzaRepo())..add(GetPizza()),
              ),
            ],
            child: HomeScreen(userData: globals.currentUser),
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}
