import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.status(status);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(status.label,
            style: TextStyle(
                color: c, fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }
}
