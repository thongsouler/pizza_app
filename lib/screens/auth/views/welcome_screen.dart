import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';
import '../blocs/sing_in_bloc/sign_in_bloc.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(initialIndex: 0, length: 1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Align(
                  alignment: const AlignmentDirectional(20, -1.2),
                  child: Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(2.7, -1.2),
                  child: Container(
                    height: MediaQuery.of(context).size.width / 1.3,
                    width: MediaQuery.of(context).size.width / 1.3,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.yellow),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
                  child: Container(),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              0.9, // Smaller width
                          height: MediaQuery.of(context).size.width *
                              0.2, // Smaller height
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20), // Circular shape
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: TabBar(
                          controller: tabController,
                          unselectedLabelColor: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.5),
                          labelColor:
                              Theme.of(context).colorScheme.onBackground,
                          tabs: [
                            Padding(
                                padding: EdgeInsets.all(12.0),
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    ColorizeAnimatedText(
                                      'STEM - THCS HẢI XUÂN',
                                      textAlign: TextAlign.center,
                                      textStyle: const TextStyle(
                                        fontSize: 40.0,
                                        fontFamily: 'Horizon',
                                        shadows: [
                                          Shadow(
                                            offset: Offset(4.0,
                                                4.0), // Horizontal and vertical shadow offset
                                            blurRadius: 10.0, // The blur effect
                                            color:
                                                Colors.black54, // Shadow color
                                          ),
                                          Shadow(
                                            offset: Offset(-4.0,
                                                -4.0), // Additional shadow for depth
                                            blurRadius: 8.0,
                                            color: Colors.black26,
                                          ),
                                        ],
                                      ),
                                      colors: [
                                        Colors.white,
                                        Colors.red,
                                        Colors.yellow
                                      ],
                                    ),
                                  ],
                                  totalRepeatCount: 4,
                                  pause: const Duration(milliseconds: 500),
                                  displayFullTextOnTap: true,
                                  stopPauseOnTap: false,
                                )),
                            // Padding(
                            //   padding: EdgeInsets.all(12.0),
                            //   child: Text(
                            //     'Sign Up',
                            //     style: TextStyle(
                            //       fontSize: 18,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: TabBarView(
                        controller: tabController,
                        children: [
                          BlocProvider<SignInBloc>(
                            create: (context) => SignInBloc(context
                                .read<AuthenticationBloc>()
                                .userRepository),
                            child: Center(child: const SignInScreen()),
                          ),
                          // BlocProvider<SignUpBloc>(
                          // 	create: (context) => SignUpBloc(
                          // 		context.read<AuthenticationBloc>().userRepository
                          // 	),
                          // 	child: const SignUpScreen(),
                          // ),
                        ],
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
