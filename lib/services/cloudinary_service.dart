import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String _cloudName = 'lpap93ab';
  static const String _uploadPreset = 'campus_care_unsigned';

  Future<String> uploadImage(XFile image) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath('file', image.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Photo upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    return data['secure_url'] as String;
  }
}