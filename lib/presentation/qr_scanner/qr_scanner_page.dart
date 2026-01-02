import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? controller;
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('扫描设备二维码'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              key: qrKey,
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                if (!isProcessing && barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('正在处理...'),
                      ],
                    )
                  : Text(
                      '将二维码放入扫描框内',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          )
        ],
      ),
    );
  }

  void _handleQRCode(String code) {
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
    });

    // 返回扫描结果
    Navigator.pop(context, code);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
