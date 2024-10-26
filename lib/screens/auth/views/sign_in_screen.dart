import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/home/blocs/get_pizza_bloc/get_pizza_bloc.dart';
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
  bool signInRequired = false;
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: BlocListener<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInSuccess) {
              setState(() {
                signInRequired = false;
              });
            } else if (state is SignInProcess) {
              setState(() {
                signInRequired = true;
              });
            } else if (state is SignInFailure) {
              setState(() {
                signInRequired = false;
                _errorMsg = 'Invalid email or password';
              });
            }
          },
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 100),
                TextButton(
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
                  child: const Text(
                    'Quét QR CCCD',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width:
                        MediaQuery.of(context).size.width / 2, // Smaller width
                    height:
                        MediaQuery.of(context).size.width / 2, // Smaller height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Circular shape
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(3, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/haixuan.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (!signInRequired)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 60,
                    child: TextButton(
                      onPressed: () {
                        globals.currentUser = MyUser(
                          userId: '88888',
                          name: 'admin',
                          idcode: '88888',
                          address: 'Hanoi',
                        );
                        context
                            .read<SignInBloc>()
                            .add(SignInRequired(globals.currentUser!));
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) {
                              return MultiBlocProvider(
                                providers: [
                                  BlocProvider(
                                    create: (context) => SignInBloc(
                                      context
                                          .read<AuthenticationBloc>()
                                          .userRepository,
                                    ),
                                  ),
                                  BlocProvider(
                                    create: (context) =>
                                        GetPizzaBloc(FirebasePizzaRepo())
                                          ..add(GetPizza()),
                                  ),
                                ],
                                child: HomeScreen(
                                  userData: globals.currentUser,
                                ),
                              );
                            },
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Text(
                          'Đăng nhập Admin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
