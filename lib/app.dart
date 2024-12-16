import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'app_view.dart';
import 'blocs/authentication_bloc/authentication_bloc.dart';

class MyApp extends StatelessWidget {
  final UserRepository userRepository;
  const MyApp(this.userRepository, {super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'), // Thêm ngôn ngữ tiếng Việt
      ],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: RepositoryProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc(
          userRepository: userRepository
        ),
        child: const MyAppView(),
      ),
    );
  }
}