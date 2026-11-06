import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enums.dart';
import '../models/incident.dart';
import 'storage_repository.dart';

class IncidentRepository {
  IncidentRepository(this._db, this._storage);
  final FirebaseFirestore _db;
  final StorageRepository _storage;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  // READ ---------------------------------------------------------------
  Stream<List<Incident>> watchAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Incident.fromDoc).toList());

  Stream<List<HistoryEntry>> watchHistory(String incidentId) => _col
      .doc(incidentId)
      .collection('history')
      .orderBy('changedAt')
      .snapshots()
      .map((s) => s.docs.map(HistoryEntry.fromDoc).toList());

  // CREATE -------------------------------------------------------------
  Future<void> create({
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    required String reporterId,
    required String reporterEmail,
    File? image,
  }) async {
    final ref = _col.doc();
    String? url;
    if (image != null) {
      url = await _storage.uploadIncidentImage(ref.id, image);
    }
    await ref.set({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'category': category.name,
      'status': IncidentStatus.submitted.value,
      'imageUrl': url,
      'reporterId': reporterId,
      'reporterEmail': reporterEmail,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': null,
    });
  }

  // UPDATE (staff only, enforced by Firestore rules) --------------------
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    required String staffId,
    String note = '',
  }) async {
    final ref = _col.doc(incidentId);
    final batch = _db.batch();
    batch.update(ref, {
      'status': status.value,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': staffId,
    });
    batch.set(ref.collection('history').doc(), {
      'status': status.value,
      'changedBy': staffId,
      'note': note.trim(),
      'changedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  // DELETE -------------------------------------------------------------
  Future<void> delete(String incidentId) async {
    await _col.doc(incidentId).delete();
    await _storage.deleteIncidentImage(incidentId);
  }
}
