import 'package:flutter/material.dart';

enum IncidentCategory {
  water('Water', Icons.water_drop),
  electricity('Electricity', Icons.bolt),
  facilities('Facilities', Icons.apartment),
  furniture('Furniture', Icons.chair_alt),
  sanitation('Sanitation', Icons.cleaning_services),
  safety('Safety', Icons.health_and_safety);

  const IncidentCategory(this.label, this.icon);
  final String label;
  final IconData icon;

  static IncidentCategory fromName(String? n) => values.firstWhere(
        (e) => e.name == n,
        orElse: () => IncidentCategory.facilities,
      );
}

enum IncidentStatus {
  submitted('submitted', 'Submitted', Colors.blueGrey),
  inReview('in_review', 'In review', Colors.orange),
  inProgress('in_progress', 'In progress', Colors.blue),
  resolved('resolved', 'Resolved', Colors.green);

  const IncidentStatus(this.value, this.label, this.color);
  final String value; // stored in Firestore
  final String label;
  final Color color;

  static IncidentStatus fromValue(String? v) => values.firstWhere(
        (e) => e.value == v,
        orElse: () => IncidentStatus.submitted,
      );
}
