import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/components/custom_appbar.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/auth/views/welcome_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:pizza_app/globals.dart' as globals;

class DetailsScreen extends StatefulWidget {
  final Pizza pizza;
  const DetailsScreen(this.pizza, {super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final SignInBloc manager;

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(manager: manager),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            children: [
              _buildPizzaImage(context),
              const SizedBox(height: 30),
              _buildDetailsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPizzaImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.height * 0.6,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 5),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          widget.pizza.picture ?? '',
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image.asset(
              'assets/haixuan.jpg',
              fit: BoxFit.fitHeight,
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.grey, offset: Offset(3, 3), blurRadius: 5),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildBuildingInfo(),
            const SizedBox(height: 10),
            _buildActionButton(context, "Xem", () {
              manager.add(UpdatePlaceRequested(
                  globals.currentUser!, widget.pizza.name ?? ""));
              _showImage(context);
            }),
            const SizedBox(height: 10),
            _buildActionButton(context, "In chỉ dẫn", () {
              manager.add(SignOutRequired());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingInfo() {
    return Column(
      children: [
        Text(
          widget.pizza.name ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoColumn("Dãy Nhà", widget.pizza.row ?? ''),
            _buildInfoColumn("Tầng", widget.pizza.floor ?? ''),
            _buildInfoColumn("Phòng", widget.pizza.room ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          elevation: 3.0,
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showImage(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.height * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey, offset: Offset(3, 3), blurRadius: 5),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  widget.pizza.picture ?? '',
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/haixuan.jpg',
                      fit: BoxFit.fitHeight,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPopupButton(context, "Đóng", Colors.lightGreen, () {
                  Navigator.pop(context);
                }),
                _buildPopupButton(context, "Kết thúc", Colors.red, () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                    (route) => false, // This will remove all previous routes
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return TextButton(
      style: TextButton.styleFrom(
        elevation: 3.0,
        backgroundColor: color,
        minimumSize: const Size(100, 60),
        side: BorderSide(color: color, width: 2),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
