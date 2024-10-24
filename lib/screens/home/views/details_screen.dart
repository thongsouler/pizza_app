import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pizza_app/app_view.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_repository/pizza_repository.dart';
import '../../../components/macro.dart';
import '../../auth/blocs/sing_in_bloc/sign_in_bloc.dart';

class DetailsScreen extends StatelessWidget {
  final Pizza pizza;
  const DetailsScreen(this.pizza, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, snapshot) {
      return BlocProvider<SignInBloc>(
        create: (context) =>
            SignInBloc(context.read<AuthenticationBloc>().userRepository),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Colors.lightGreen,
            title: Text(pizza.name),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(3, 3),
                            blurRadius: 5)
                      ],
                      image: DecorationImage(
                          image: NetworkImage(pizza.picture),
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(3, 3),
                            blurRadius: 5)
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  pizza.name,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        pizza.description,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor: Colors.lightGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                "In chỉ dẫn",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Nút Xem
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                // Hiển thị popup với hình ảnh
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (tcontext) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    content: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.9,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.network(
                                            pizza.picture,
                                            fit: BoxFit.contain,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.7, // Chiều cao của ảnh trong popup
                                            // width: 200,
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  elevation: 3.0,
                                                  backgroundColor:
                                                      Colors.lightGreen,

                                                  side: BorderSide(
                                                      color: Colors.lightGreen,
                                                      width:
                                                          2), // Viền màu xanh
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Đóng popup
                                                },
                                                child: const Text(
                                                  "Đóng",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  elevation: 3.0,
                                                  backgroundColor:
                                                      Colors.lightGreen,

                                                  side: BorderSide(
                                                      color: Colors.lightGreen,
                                                      width:
                                                          2), // Viền màu xanh
                                                ),
                                                onPressed: () {
                                                  context
                                                      .read<SignInBloc>()
                                                      .add(SignOutRequired());
                                                },
                                                child: const Text(
                                                  "Kết thúc",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                elevation: 3.0,
                                backgroundColor: Colors.lightGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                "Xem",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
