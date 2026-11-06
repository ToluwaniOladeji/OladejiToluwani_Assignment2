import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

DateTime _ts(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();

class Incident {
  final String id;
  final String title;
  final String description;
  final String location;
  final IncidentCategory category;
  final IncidentStatus status;
  final String? imageUrl;
  final String reporterId;
  final String reporterEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.reporterId,
    required this.reporterEmail,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.updatedBy,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      category: IncidentCategory.fromName(d['category']),
      status: IncidentStatus.fromValue(d['status']),
      imageUrl: d['imageUrl'],
      reporterId: d['reporterId'] ?? '',
      reporterEmail: d['reporterEmail'] ?? '',
      createdAt: _ts(d['createdAt']),
      updatedAt: _ts(d['updatedAt']),
      updatedBy: d['updatedBy'],
    );
  }
}

/// One status change, stored in incidents/{id}/history.
class HistoryEntry {
  final String id;
  final IncidentStatus status;
  final String changedBy;
  final String note;
  final DateTime changedAt;

  const HistoryEntry({
    required this.id,
    required this.status,
    required this.changedBy,
    required this.note,
    required this.changedAt,
  });

  factory HistoryEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return HistoryEntry(
      id: doc.id,
      status: IncidentStatus.fromValue(d['status']),
      changedBy: d['changedBy'] ?? '',
      note: d['note'] ?? '',
      changedAt: _ts(d['changedAt']),
    );
  }
}
