import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();
  static const Uuid _uuid = Uuid();

  /// Pick an image from gallery or camera
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int imageQuality = 85,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Compress and resize image
  static Future<Uint8List> compressImage(File imageFile) async {
    try {
      // Read the image file
      final Uint8List bytes = await imageFile.readAsBytes();

      // Decode the image
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if it's too large
      img.Image resizedImage = image;
      if (image.width > 1024 || image.height > 1024) {
        resizedImage = img.copyResize(
          image,
          width: 1024,
          height: 1024,
          interpolation: img.Interpolation.linear,
        );
      }

      // Convert to JPEG format with quality 85
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      return compressedBytes;
    } catch (e) {
      print('Error compressing image: $e');
      rethrow;
    }
  }

  /// Generate unique filename for image
  static String generateImageFileName(String originalFileName) {
    final String extension = path.extension(originalFileName);
    final String uniqueId = _uuid.v4();
    return 'items/$uniqueId$extension';
  }

  /// Upload image to storage bucket
  /// This is a placeholder - you'll need to implement actual upload logic
  /// based on your storage solution (Firebase Storage, AWS S3, etc.)
  static Future<String?> uploadImageToBucket(File imageFile) async {
    try {
      // Compress the image
      final Uint8List compressedBytes = await compressImage(imageFile);

      // Generate unique filename
      final String fileName = generateImageFileName(imageFile.path);

      // TODO: Implement actual upload to your storage bucket
      // This is where you would upload to Firebase Storage, AWS S3, or your preferred storage

      // For demo purposes, we'll simulate a successful upload
      // In a real implementation, you would:
      // 1. Upload the compressed bytes to your storage service
      // 2. Get the public URL back from the storage service
      // 3. Return the public URL

      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));

      // Return a mock URL for demonstration
      final String imageUrl =
          'https://storage.googleapis.com/stocked-bucket/$fileName';

      print('Image uploaded successfully: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from storage bucket
  static Future<bool> deleteImageFromBucket(String imageUrl) async {
    try {
      // TODO: Implement actual deletion from your storage bucket
      // This is where you would delete from Firebase Storage, AWS S3, etc.

      // Simulate deletion delay
      await Future.delayed(const Duration(seconds: 1));

      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}
