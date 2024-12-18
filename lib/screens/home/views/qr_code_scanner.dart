import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pizza_app/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:pizza_app/screens/auth/blocs/sing_in_bloc/sign_in_bloc.dart';
import 'package:pizza_app/screens/home/blocs/places/get_place_bloc.dart';

import 'package:pizza_app/screens/home/views/home_screen.dart';
import 'package:pizza_repository/pizza_repository.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:user_repository/user_repository.dart';

class QrScanScreen extends StatefulWidget {
  @override
  _QrScanScreenState createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrCodeResult = '';
  late final SignInBloc manager;

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
    manager = context.read<SignInBloc>();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation =
        Tween<double>(begin: -125, end: 125).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quét Mã QR',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.green,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: 300, // Tăng kích thước ô quét QR
            ),
          ),
          _buildScanningEffect(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _processScannedData(scanData.code!);
      }
    });
  }

  Future<void> _processScannedData(String data) async {
    controller?.pauseCamera();
    setState(() {
      qrCodeResult = data;
    });
    var rs = parseUserData(qrCodeResult);
    if (rs.idcode == 'N/A') {
      showErrorSnackbar("Khôg đúng định dạng mã QR CCCD");
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);
      return;
    }
    context.read<SignInBloc>().add(SignInRequired(rs));
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
            child: HomeScreen(userData: rs),
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  MyUser parseUserData(String data) {
    try {
      List<String> parts = data.split('|');
      if (parts.length < 6) throw FormatException("Dữ liệu không đủ thông tin");

      String idCode = parts[0];
      String name = parts[2];
      String address = parts[5];

      return MyUser(
        idcode: idCode,
        name: name,
        address: address,
      );
    } catch (e) {
      return MyUser(idcode: 'N/A', name: 'Unknown', address: 'Unknown');
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildScanningEffect() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 250,
            height: 5,
            color: Colors.green.withOpacity(0.7),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
