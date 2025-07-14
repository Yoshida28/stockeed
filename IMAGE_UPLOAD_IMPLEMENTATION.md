# Image Upload Implementation Guide

This document explains how to implement actual image upload functionality for the Stocked app.

## Current Implementation

The app currently includes a mock image upload service (`ImageUploadService`) that simulates the upload process. To implement real image upload functionality, you'll need to replace the mock implementation with actual storage service integration.

## Storage Options

### 1. Firebase Storage (Recommended)

Firebase Storage is a popular choice for Flutter apps. Here's how to implement it:

#### Setup
1. Add Firebase to your project:
   ```bash
   flutter pub add firebase_core firebase_storage
   ```

2. Configure Firebase in your project following the official documentation.

#### Implementation
Replace the `uploadImageToBucket` method in `ImageUploadService`:

```dart
import 'package:firebase_storage/firebase_storage.dart';

static Future<String?> uploadImageToBucket(File imageFile) async {
  try {
    // Compress the image
    final Uint8List compressedBytes = await compressImage(imageFile);
    
    // Generate unique filename
    final String fileName = generateImageFileName(imageFile.path);
    
    // Upload to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = storageRef.putData(compressedBytes);
    
    // Wait for upload to complete
    final snapshot = await uploadTask;
    
    // Get download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    print('Image uploaded successfully: $downloadUrl');
    return downloadUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
```

### 2. AWS S3

For AWS S3 integration:

#### Setup
1. Add AWS dependencies:
   ```bash
   flutter pub add aws_s3_upload
   ```

#### Implementation
```dart
import 'package:aws_s3_upload/aws_s3_upload.dart';

static Future<String?> uploadImageToBucket(File imageFile) async {
  try {
    // Compress the image
    final Uint8List compressedBytes = await compressImage(imageFile);
    
    // Generate unique filename
    final String fileName = generateImageFileName(imageFile.path);
    
    // Configure AWS S3
    final awsS3 = AwsS3(
      accessKey: 'YOUR_ACCESS_KEY',
      secretKey: 'YOUR_SECRET_KEY',
      region: 'YOUR_REGION',
      bucketName: 'YOUR_BUCKET_NAME',
    );
    
    // Upload file
    final result = await awsS3.uploadFile(
      file: compressedBytes,
      key: fileName,
      contentType: 'image/jpeg',
    );
    
    if (result.isSuccess) {
      final imageUrl = 'https://${awsS3.bucketName}.s3.${awsS3.region}.amazonaws.com/$fileName';
      return imageUrl;
    }
    
    return null;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
```

### 3. Supabase Storage

For Supabase integration:

#### Setup
1. Add Supabase dependencies:
   ```bash
   flutter pub add supabase_flutter
   ```

#### Implementation
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

static Future<String?> uploadImageToBucket(File imageFile) async {
  try {
    // Compress the image
    final Uint8List compressedBytes = await compressImage(imageFile);
    
    // Generate unique filename
    final String fileName = generateImageFileName(imageFile.path);
    
    // Upload to Supabase Storage
    final response = await Supabase.instance.client.storage
        .from('items')
        .uploadBinary(fileName, compressedBytes);
    
    // Get public URL
    final imageUrl = Supabase.instance.client.storage
        .from('items')
        .getPublicUrl(fileName);
    
    return imageUrl;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
```

## Database Integration

The app is already configured to store image URLs in the database. The `Item` model includes an `imageUrl` field that gets saved to the database when items are created or updated.

## Security Considerations

1. **File Size Limits**: The current implementation compresses images to 1024x1024 pixels and 85% quality to reduce file sizes.

2. **File Type Validation**: Consider adding validation to ensure only image files are uploaded.

3. **Access Control**: Implement proper access control in your storage service to prevent unauthorized access.

4. **CDN**: Consider using a CDN for better image delivery performance.

## Environment Configuration

Create environment-specific configuration files:

```dart
// lib/core/config/storage_config.dart
class StorageConfig {
  static const String bucketUrl = String.fromEnvironment(
    'STORAGE_BUCKET_URL',
    defaultValue: 'https://your-storage-bucket.com',
  );
  
  static const String apiKey = String.fromEnvironment('STORAGE_API_KEY');
  static const String secretKey = String.fromEnvironment('STORAGE_SECRET_KEY');
}
```

## Testing

To test the image upload functionality:

1. Run the app in debug mode
2. Navigate to Stock Management
3. Click "Add Item"
4. Select an image from gallery or camera
5. Upload the image
6. Verify the image appears in the item list and detail view

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your app has proper permissions for camera and gallery access.

2. **Upload Failures**: Check your internet connection and storage service configuration.

3. **Image Not Displaying**: Verify the image URL is accessible and the image format is supported.

### Debug Tips

1. Enable verbose logging in your storage service
2. Check network requests in browser developer tools
3. Verify file sizes and formats before upload
4. Test with different image types and sizes

## Next Steps

1. Choose your preferred storage service
2. Implement the actual upload functionality
3. Add proper error handling and retry logic
4. Implement image deletion when items are deleted
5. Add image optimization and caching
6. Consider implementing image editing features 