import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pizza_app/app_view.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/screens/auth/views/welcome_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isPushLoginScreen;
  final SignInBloc manager;

  const CustomAppBar(
      {super.key, required this.manager, this.isPushLoginScreen = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 55, 190, 252),
      iconTheme: IconThemeData(color: Colors.white),
      title: const Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 30,
          ),
          Spacer(),
          Text(
            'THCS HẢI XUÂN',
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
          ),
          Spacer(),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            context.read<SignInBloc>().add(SignOutRequired());
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MyAppView()),
                (route) => false, // This will remove all previous routes
              );
            });
          },
          icon: const Icon(
            Icons.logout_outlined,
            size: 30,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
