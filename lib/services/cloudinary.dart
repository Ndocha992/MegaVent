import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:megavent/utils/constants.dart';
import 'package:path/path.dart' as path;

class Cloudinary {
  // Upload preset name (create this in your Cloudinary dashboard)
  static const String _uploadPreset = 'megavent_images';

  // Specific method for event banner uploads
  static Future<String?> uploadEventBanner(
    File file, {
    required String eventId,
    String? eventName,
  }) async {
    final sanitizedEventName = eventName?.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_') ?? 'event';
    final title = '${eventId}_${sanitizedEventName}_banner';
    return await _uploadToCloudinaryWithPreset(
      file: file,
      title: title,
      folder: 'megavent/event_banners',
    );
  }

  // Modified method using upload preset with folder support
  static Future<String?> _uploadToCloudinaryWithPreset({
    required File file,
    String? title,
    String? folder,
  }) async {
    try {
      // Prepare the file name with timestamp to ensure uniqueness
      final fileName = title ?? path.basename(file.path);
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final randomSuffix = (DateTime.now().microsecond % 1000).toString();
      final publicId = '${fileName}_${uniqueId}_$randomSuffix'.replaceAll(' ', '_');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${Constants.cloudinaryCloudName}/auto/upload'),
      );

      // Add fields for unsigned upload with preset
      final fields = {
        'upload_preset': _uploadPreset,
        'public_id': publicId,
      };

      // Add folder if specified
      if (folder != null) {
        fields['folder'] = folder;
      }

      request.fields.addAll(fields);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      // Send request with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout - please check your internet connection');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        return responseJson['secure_url'];
      } else {
        print('Cloudinary upload error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Method to delete an image from Cloudinary (requires signed request)
  static Future<bool> deleteImage(String publicId) async {
    try {
      // Generate timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create signature for deletion
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp${Constants.cloudinaryApiSecret}';
      final signature = sha1.convert(utf8.encode(stringToSign)).toString();

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/${Constants.cloudinaryCloudName}/image/destroy'),
        body: {
          'public_id': publicId,
          'api_key': Constants.cloudinaryApiKey,
          'timestamp': timestamp,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final responseJson = json.decode(response.body);
        return responseJson['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('Error deleting from Cloudinary: $e');
      return false;
    }
  }
}