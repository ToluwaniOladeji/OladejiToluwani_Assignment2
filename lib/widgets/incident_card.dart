import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../theme/app_theme.dart';
import '../utils/time_ago.dart';
import 'app_card.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap});
  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _Thumb(incident),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.place_outlined,
                      size: 14, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(incident.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusChip(incident.status),
                    Text(timeAgo(incident.createdAt),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.incident);
  final Incident incident;

  Widget _iconTile() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(incident.category.icon, color: AppColors.primary),
      );

  @override
  Widget build(BuildContext context) {
    final url = incident.imageUrl;
    if (url == null) return _iconTile();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        url,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _iconTile(),
        loadingBuilder: (_, child, p) => p == null
            ? child
            : Container(
                width: 60, height: 60, color: AppColors.primarySoft),
      ),
    );
  }
}
