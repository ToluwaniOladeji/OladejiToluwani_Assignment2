import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/page_header.dart';
import '../../widgets/section_header.dart';
import '../../widgets/summary_tile.dart';
import '../shared/report_detail_screen.dart';

/// Staff-only landing page: counts by status, resolution rate, and the
/// reports that are still waiting for a first response.
class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AsyncValueView<List<Incident>>(
      value: ref.watch(incidentsStreamProvider),
      onRetry: () => ref.invalidate(incidentsStreamProvider),
      data: (all) {
        int count(IncidentStatus s) => all.where((i) => i.status == s).length;
        final pending = all
            .where((i) => i.status == IncidentStatus.submitted)
            .take(10)
            .toList();
        final rate = all.isEmpty
            ? 0.0
            : count(IncidentStatus.resolved) / all.length;

        Widget tile(IncidentStatus s) => Expanded(
              child: SummaryTile(
                  count: count(s), label: s.label, color: AppColors.status(s)),
            );

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const PageHeader('Dashboard', subtitle: 'Where campus reports stand today'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                Row(children: [
                  tile(IncidentStatus.submitted),
                  const SizedBox(width: 8),
                  tile(IncidentStatus.inReview),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  tile(IncidentStatus.inProgress),
                  const SizedBox(width: 8),
                  tile(IncidentStatus.resolved),
                ]),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Resolution rate', style: theme.textTheme.titleMedium),
                          Text('${(rate * 100).round()}%',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rate,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${count(IncidentStatus.resolved)} of ${all.length} reports resolved',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ]),
            ),
            const SectionHeader('Awaiting review'),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Nothing waiting. All caught up.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.muted)),
              ),
            for (final i in pending)
              IncidentCard(
                incident: i,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(incidentId: i.id))),
              ),
          ],
        );
      },
    );
  }
}
