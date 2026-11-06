import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageRepository {
  StorageRepository(this._storage);
  final FirebaseStorage _storage;

  Future<String> uploadIncidentImage(String incidentId, File file) async {
    final ref = _storage.ref('incident_images/$incidentId.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> deleteIncidentImage(String incidentId) async {
    try {
      await _storage.ref('incident_images/$incidentId.jpg').delete();
    } catch (_) {/* image may not exist */}
  }
}
