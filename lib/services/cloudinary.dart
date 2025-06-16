import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:megavent/utils/constants.dart';
import 'package:path/path.dart' as path;

class Cloudinary {
  // Upload preset name (create this in your Cloudinary dashboard)
  static const String _uploadPreset = 'fintech_bridge_docs';
  
  // Original upload method (keeping for backward compatibility)
  static Future<String?> uploadFile(File file, {String? title}) async {
    return await _uploadToCloudinary(
      file: file,
      title: title,
      folder: 'FinTech Bridge Files',
    );
  }

  // Specific method for identification documents using upload preset
  static Future<String?> uploadIdentificationImage(
    File file, {
    required String userId,
    required String documentType, // e.g., 'national_id_front', 'student_id_back'
  }) async {
    final title = '${userId}_$documentType';
    return await _uploadToCloudinaryWithPreset(
      file: file,
      title: title,
    );
  }

  // NEW: Specific method for provider identification documents
  static Future<String?> uploadProviderIdentificationImage(
    File file, {
    required String userId,
    required String documentType, // e.g., 'business_license_front', 'tax_certificate'
  }) async {
    final title = '${userId}_$documentType';
    return await _uploadToCloudinaryWithPreset(
      file: file,
      title: title,
    );
  }

  // Batch upload for multiple identification images (students)
  static Future<Map<String, String?>> uploadIdentificationImages({
    required String userId,
    required File nationalIdFront,
    required File nationalIdBack,
    required File studentIdFront,
    required File studentIdBack,
  }) async {
    final results = <String, String?>{};
    
    // Upload all images concurrently for better performance
    final futures = [
      uploadIdentificationImage(
        nationalIdFront,
        userId: userId,
        documentType: 'national_id_front',
      ),
      uploadIdentificationImage(
        nationalIdBack,
        userId: userId,
        documentType: 'national_id_back',
      ),
      uploadIdentificationImage(
        studentIdFront,
        userId: userId,
        documentType: 'student_id_front',
      ),
      uploadIdentificationImage(
        studentIdBack,
        userId: userId,
        documentType: 'student_id_back',
      ),
    ];

    final urls = await Future.wait(futures);
    
    results['nationalIdFront'] = urls[0];
    results['nationalIdBack'] = urls[1];
    results['studentIdFront'] = urls[2];
    results['studentIdBack'] = urls[3];

    return results;
  }

  // NEW: Batch upload for provider identification images
  static Future<Map<String, String?>> uploadProviderIdentificationImages({
    required String userId,
    required File businessLicenseFront,
    required File businessLicenseBack,
    required File taxCertificate,
    required File bankStatement,
  }) async {
    final results = <String, String?>{};
    
    // Upload all images concurrently for better performance
    final futures = [
      uploadProviderIdentificationImage(
        businessLicenseFront,
        userId: userId,
        documentType: 'business_license_front',
      ),
      uploadProviderIdentificationImage(
        businessLicenseBack,
        userId: userId,
        documentType: 'business_license_back',
      ),
      uploadProviderIdentificationImage(
        taxCertificate,
        userId: userId,
        documentType: 'tax_certificate',
      ),
      uploadProviderIdentificationImage(
        bankStatement,
        userId: userId,
        documentType: 'bank_statement',
      ),
    ];

    final urls = await Future.wait(futures);
    
    results['businessLicenseFront'] = urls[0];
    results['businessLicenseBack'] = urls[1];
    results['taxCertificate'] = urls[2];
    results['bankStatement'] = urls[3];

    return results;
  }

  // New method using upload preset (unsigned upload)
  static Future<String?> _uploadToCloudinaryWithPreset({
  required File file,
  String? title,
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
      'upload_preset': _uploadPreset, // Make sure this preset exists and is unsigned
      'public_id': publicId, // Unique ID prevents conflicts without overwrite
      // Note: overwrite, folder, transformation are configured in the preset
    };

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

  // Original private method (keeping for backward compatibility with signed uploads)
  static Future<String?> _uploadToCloudinary({
    required File file,
    String? title,
    String folder = 'FinTech Bridge Files',
    String? transformation,
  }) async {
    try {
      // Prepare the file name
      final fileName = title ?? path.basename(file.path);
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      final publicId = '${fileName}_$uniqueId'.replaceAll(' ', '_');

      // For signed upload, we need to create a signature
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Parameters for signature
      final params = {
        'folder': folder,
        'public_id': publicId,
        'overwrite': 'true',
        'context': 'author=FinTech Bridge',
        'resource_type': 'auto',
        'timestamp': timestamp,
      };

      if (transformation != null) {
        params['transformation'] = transformation;
      }

      // Create signature string
      final sortedParams = params.keys.toList()..sort();
      final paramString = sortedParams
          .map((key) => '$key=${params[key]}')
          .join('&');
      final stringToSign = '$paramString${Constants.cloudinaryApiSecret}';
      final signature = sha1.convert(utf8.encode(stringToSign)).toString();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${Constants.cloudinaryCloudName}/auto/upload'),
      );

      // Add all fields including signature
      final fields = Map<String, String>.from(params);
      fields['api_key'] = Constants.cloudinaryApiKey;
      fields['signature'] = signature;

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