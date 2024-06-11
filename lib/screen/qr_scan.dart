import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//platfform check
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  final String assetName = 'assets/images/Ebene 1.svg';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 253, 244, 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SvgPicture.asset(
                  assetName,
                ),
              ),
              //scanner
              Expanded(flex: 2, child: _buildQrView(context)),
              if (result != null)
              //qr data
                Text(
                    'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
              else
                const Text('Scan a code'),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Scannen Sie den QR-Code',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10),
                      child: Text(
                        'Scannen Sie den QR-Code auf der Unterseite des Gateways, um die Installation fortzusetzen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    //flash on off
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsets.all(8),
                            child: IconButton(
                                onPressed: () async {
                                  await controller?.toggleFlash();
                                  setState(() {});
                                },
                                icon: FutureBuilder(
                                  future: controller?.getFlashStatus(),
                                  builder: (context, snapshot) {
                                    return snapshot.data.toString() == 'true'
                                        ? Icon(Icons.flash_on)
                                        : Icon(Icons.flash_off);
                                  },
                                ))),
                                //camera flip
                        IconButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            icon: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return '${describeEnum(snapshot.data!.toString())}' ==
                                          'back'
                                      ? Icon(Icons.video_camera_back)
                                      : Icon(Icons.video_camera_front);
                                }
                                return Icon(Icons.camera);
                              },
                            )),//pause camera
                            IconButton(onPressed:() async {
                              await controller?.pauseCamera();
                            }, icon: Icon(Icons.pause)),
                            //resume camera
                      IconButton(onPressed: ()async {
                              await controller?.resumeCamera();
                            }, icon: Icon(Icons.restore_rounded))
                      ],
                    ),
                   
                        
                      
                    
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // provide area for scanning on screen
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    //checks the size of screen
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.black,
          borderRadius: 35,
          borderLength: 40,
          overlayColor: Color.fromRGBO(255, 253, 244, 1),
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

//functions
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

//permission check
  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
