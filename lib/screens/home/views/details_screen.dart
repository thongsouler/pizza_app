import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/app_view.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/components/custom_appbar.dart';
import 'package:pizza_app/components/print_widget.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    manager = context.read<SignInBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final List<String> pictures = widget.pizza.pictures ?? []; // Danh sách ảnh

    if (pictures.isEmpty) {
      // Nếu không có ảnh nào
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
        child: Image.asset(
          'assets/building.png', // Hiển thị ảnh mặc định
          fit: BoxFit.cover,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.height * 0.6,
          height: MediaQuery.of(context).size.height * 0.6,
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
            child: PageView.builder(
              controller: _pageController,
              itemCount: pictures.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  pictures[index],
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/building.png', // Hiển thị ảnh mặc định nếu lỗi
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${_currentPage + 1} / ${pictures.length}', // Hiển thị số ảnh hiện tại
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
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
            _buildActionButton(context, "In chỉ dẫn", () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PrintWidget(
                            imageUrl: widget.pizza.pictures![0],
                            textToPrint: removeDiacritics(
                              '''${widget.pizza.name}\n Dãy nhà ${widget.pizza.row} - Tầng ${widget.pizza.floor} - Phòng ${widget.pizza.room}''',
                            ),
                          )));

              if (result == true) {
                context.read<SignInBloc>().add(SignOutRequired());
                Future.delayed(const Duration(milliseconds: 100), () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyAppView()),
                    (route) => false,
                  );
                });
              }
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
          backgroundColor: const Color.fromARGB(255, 55, 190, 252),
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
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: widget.pizza.pictures?.length ?? 0,
                  itemBuilder: (context, index) {
                    final imageUrl = widget.pizza.pictures?[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(3, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            imageUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Image.asset(
                                'assets/building.png',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPopupButton(
                    context,
                    "Đóng",
                    const Color.fromARGB(255, 55, 190, 252),
                    () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
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
