import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/places/get_place_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';

import 'screens/auth/views/welcome_screen.dart';
import 'screens/home/views/home_screen.dart';
import 'package:pizza_app/globals.dart' as globals;

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: globals.schoolName.toUpperCase(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme: ColorScheme.light(
                background: Colors.grey.shade200,
                onBackground: Colors.black,
                primary: Colors.blue,
                onPrimary: Colors.white)),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  SignInBloc(context.read<AuthenticationBloc>().userRepository),
            ),
            BlocProvider(
              create: (context) =>
                  GetPizzaBloc(FirebasePizzaRepo())..add(GetPizza()),
            ),
          ],
          child: const WelcomeScreen(),
        ));
  }
}
