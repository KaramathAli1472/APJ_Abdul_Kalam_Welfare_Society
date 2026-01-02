import 'dart:io';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/cloudinary_media.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Aapka Cloudinary cloud name
  static const String cloudName = 'drxe5e2nk';
  
  // Initialize Cloudinary
  static void initialize() {
    CloudinaryContext.cloudinary = CloudinaryContext(
      cloudName: cloudName,
    );
    print('✅ Cloudinary Initialized with cloud name: $cloudName');
  }
  
  // Image upload karne ka function
  static Future<String?> uploadStudentImage(File imageFile, String studentEmail) async {
    try {
      print('🔄 Cloudinary mein student image upload kar raha hoon...');
      
      final cloudinary = CloudinaryContext.cloudinary!;
      final response = await cloudinary.upload(
        file: imageFile.path,
        resourceType: CloudinaryResourceType.image,
        folder: 'student_photos',
        fileName: 'student_${studentEmail}_${DateTime.now().millisecondsSinceEpoch}',
        progressCallback: (count, total) {
          final progress = (count / total * 100).toStringAsFixed(2);
          print('📤 Upload progress: $progress%');
        },
      );
      
      print('✅ Image uploaded successfully!');
      print('🔗 URL: ${response.secureUrl}');
      print('📁 Public ID: ${response.publicId}');
      
      return response.secureUrl;
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return null;
    }
  }
  
  // Gallery se image pick karna
  static Future<File?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Image pick error: $e');
      return null;
    }
  }
  
  // Camera se image pick karna
  static Future<File?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Camera error: $e');
      return null;
    }
  }
  
  // URL se image download karna (agar email se aaya hai)
  static Future<File?> downloadImageFromUrl(String imageUrl) async {
    try {
      print('📥 Downloading image from URL: $imageUrl');
      
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Temporary file create karein
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/student_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);
        
        print('✅ Image downloaded successfully');
        return tempFile;
      }
      return null;
    } catch (e) {
      print('❌ Image download error: $e');
      return null;
    }
  }
  
  // Check karein ki image URL Cloudinary se hai ya nahi
  static bool isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com') || url.contains('res.cloudinary.com');
  }
}