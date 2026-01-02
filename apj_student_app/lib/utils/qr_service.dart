import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class QRService {
  // QR Code generate karna
  static Widget generateStudentQRCode({
    required String studentId,
    required String studentName,
    required String registrationNumber,
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    // Student data JSON format mein
    final qrData = '''
{
  "student_id": "$studentId",
  "name": "$studentName",
  "registration_number": "$registrationNumber",
  "school": "A.P.J Abdul Kalam Welfare Society",
  "timestamp": "${DateTime.now().toIso8601String()}"
}
''';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 2),
        color: backgroundColor,
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: size,
            gapless: false,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.blue,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            studentName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          Text(
            registrationNumber,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // Payment QR Code generate karna
  static Widget generatePaymentQRCode({
    required double amount,
    required String studentName,
    required String studentId,
    double size = 200,
  }) {
    // UPI Payment URL
    final upiUrl = 'upi://pay?pa=abdulkalamwelfare@upi&pn=$studentName&am=$amount&tn=Fee%20Payment&cu=INR';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green, width: 2),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: upiUrl,
            version: QrVersions.auto,
            size: size,
            gapless: false,
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
          ),
          SizedBox(height: 8),
          Text(
            'Payment QR Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          Text(
            'Amount: ₹$amount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            'Student: $studentName',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  // QR Code ko image file mein save karna
  static Future<File?> saveQRCodeToFile({
    required String data,
    required String fileName,
  }) async {
    try {
      // QR Code painter create karein
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        color: Colors.black,
        emptyColor: Colors.white,
        gapless: false,
      );
      
      // Convert to image
      final picData = await qrPainter.toImageData(300);
      if (picData == null) return null;
      
      // Convert to bytes
      final byteData = await picData.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;
      
      final bytes = byteData.buffer.asUint8List();
      
      // File save karein
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.png';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      print('✅ QR Code saved at: $filePath');
      return file;
    } catch (e) {
      print('❌ Error saving QR Code: $e');
      return null;
    }
  }
  
  // QR Code display dialog
  static void showQRCodeDialog({
    required BuildContext context,
    required Widget qrWidget,
    String title = 'QR Code',
    VoidCallback? onSave,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code, color: Colors.blue),
            SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            qrWidget,
            SizedBox(height: 10),
            Text(
              'Scan this QR code',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: onSave,
            child: Row(
              children: [
                Icon(Icons.download),
                SizedBox(width: 5),
                Text('Save QR'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}