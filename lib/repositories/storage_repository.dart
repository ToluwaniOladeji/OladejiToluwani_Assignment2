import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class StorageRepository {
  static const _cloudName = 'om5ul9ep';
  static const _preset = 'campus_incident_app';

  Future<String> uploadIncidentImage(String incidentId, File file) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
    )
      ..fields['upload_preset'] = _preset
      ..fields['public_id'] = 'incident_$incidentId'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode != 200) {
      throw Exception('Image upload failed. Please try again.');
    }
    return jsonDecode(body)['secure_url'] as String;
  }

  // Unsigned uploads can't be deleted from the client; the image just
  // becomes unreferenced when the Firestore document is deleted.
  Future<void> deleteIncidentImage(String incidentId) async {}
}