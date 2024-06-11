import 'package:flutter/material.dart';
import 'package:qr_app/screen/qr_scan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Code Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRViewExample(),
    );
  }
}
