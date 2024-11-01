import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class PrintingWidget extends StatefulWidget {
  final String imageUrl;
  final String textToPrint;

  const PrintingWidget({
    Key? key,
    required this.imageUrl,
    required this.textToPrint,
  }) : super(key: key);

  @override
  _PrintingWidgetState createState() => _PrintingWidgetState();
}

class _PrintingWidgetState extends State<PrintingWidget> {
  List<BluetoothInfo>? availableBluetoothDevices;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothPermission();
  }

  Future<void> _checkBluetoothPermission() async {
    var status = await Permission.bluetooth.status;
    if (!status.isGranted) {
      await Permission.bluetooth.request();
    }
    findDevices();
  }

  Future<void> findDevices() async {
    availableBluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (availableBluetoothDevices != null &&
        availableBluetoothDevices!.isNotEmpty) {
      if (availableBluetoothDevices!.length == 1) {
        await printWithDevice(availableBluetoothDevices!.first);
      } else {
        setState(() {});
      }
    } else {
      setState(() {
        availableBluetoothDevices = []; // Ensure it's not null
      });
    }
  }

  Future<void> printWithDevice(BluetoothInfo device) async {
    setState(() => _isLoading = true);

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    // Load image and print
    Uint8List imageBytes = await loadImage(widget.imageUrl);

    if (imageBytes.isNotEmpty) {
      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        List<int> bytes = [];

        // Print image
        bytes += generator.image(image);
        bytes += generator.feed(1);

        // Print text
        bytes += generator.text(widget.textToPrint,
            styles: const PosStyles(bold: true));
        bytes += generator.feed(1); // Add an empty line after the text

        await PrintBluetoothThermal.writeBytes(bytes);
      } else {
        print("Failed to decode image");
      }
    } else {
      print("Failed to load image");
    }

    setState(() => _isLoading = false);
    Navigator.pop(context);
  }

  Future<Uint8List> loadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('Failed to load image: ${response.statusCode}');
        return Uint8List(0);
      }
    } catch (e) {
      print('Error loading image: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Devices')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableBluetoothDevices != null &&
                  availableBluetoothDevices!.isNotEmpty
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    final device = availableBluetoothDevices![index];
                    return ListTile(
                      title: Text(device.name ?? 'Unknown device'),
                      subtitle: Text(device.macAdress ?? ''),
                      onTap: () => printWithDevice(device),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: availableBluetoothDevices?.length ?? 0,
                )
              : const Center(child: Text('No Bluetooth devices available.')),
    );
  }
}
