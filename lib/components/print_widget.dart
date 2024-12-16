import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:pizza_app/globals.dart' as globals;

class PrintWidget extends StatefulWidget {
  final String imageUrl;
  final String textToPrint;

  // Add imageUrl as a required parameter
  PrintWidget({required this.imageUrl, this.textToPrint = ''});

  @override
  _PrintWidgetState createState() => _PrintWidgetState();
}

class _PrintWidgetState extends State<PrintWidget> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Initialize Bluetooth
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('Current device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<String> getImageFromUrl() async {
    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        Uint8List imageBytes = response.bodyBytes;
        return base64Encode(imageBytes);
      } else {
        throw Exception("Failed to load image");
      }
    } catch (e) {
      print("Error fetching image: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'In chỉ dẫn',
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 190, 252),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address ?? ''),
                            onTap: () async {
                              setState(() {
                                _device = d;
                              });
                            },
                            trailing:
                                _device != null && _device!.address == d.address
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                          ))
                      .toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        OutlinedButton(
                          child: Text('Connect'),
                          onPressed: _connected
                              ? null
                              : () async {
                                  if (_device != null &&
                                      _device!.address != null) {
                                    setState(() {});
                                    await bluetoothPrint.connect(_device!);
                                  } else {
                                    setState(() {});
                                  }
                                },
                        ),
                        SizedBox(width: 10.0),
                        OutlinedButton(
                          child: Text('Disconnect'),
                          onPressed: _connected
                              ? () async {
                                  setState(() {});
                                  await bluetoothPrint.disconnect();
                                }
                              : null,
                        ),
                      ],
                    ),
                    Divider(),
                    TextButton(
                      style: TextButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor:
                            const Color.fromARGB(255, 55, 190, 252),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'In chỉ dẫn',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: _connected
                          ? () async {
                              String base64Image = await getImageFromUrl();

                              if (base64Image.isNotEmpty) {
                                Map<String, dynamic> config = {};

                                List<LineText> list = [
                                  LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: widget.textToPrint,
                                    weight: 2,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1,
                                  ),
                                  LineText(linefeed: 1),
                                  LineText(
                                    type: LineText.TYPE_IMAGE,
                                    content: base64Image,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1,
                                    width: 350,
                                    height: 350,
                                  ),
                                ];

                                await bluetoothPrint.printReceipt(config, list);
                                Navigator.of(context).pop(true);
                              } else {
                                setState(() {});
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothPrint.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          return FloatingActionButton(
            child: Icon(snapshot.data == true ? Icons.stop : Icons.search),
            onPressed: snapshot.data == true
                ? () => bluetoothPrint.stopScan()
                : () => bluetoothPrint.startScan(
                      timeout: Duration(seconds: 4),
                    ),
            backgroundColor: snapshot.data == true ? Colors.red : null,
          );
        },
      ),
    );
  }
}
