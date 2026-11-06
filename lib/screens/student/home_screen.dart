import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/summary_tile.dart';
import '../shared/report_detail_screen.dart';
import 'submit_report_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onSeeAll, required this.onSeeMine});
  final VoidCallback onSeeAll;
  final VoidCallback onSeeMine;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final name = (user?.displayName ?? '').trim();
    final first = name.isEmpty ? 'there' : name.split(' ').first;

    return AsyncValueView<List<Incident>>(
      value: ref.watch(incidentsStreamProvider),
      onRetry: () => ref.invalidate(incidentsStreamProvider),
      data: (all) {
        final mine = all.where((i) => i.reporterId == user?.uid).toList();
        int c(IncidentStatus s) => mine.where((i) => i.status == s).length;
        final open = c(IncidentStatus.submitted) + c(IncidentStatus.inReview);
        final recent = all.take(4).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_greeting(), style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted)),
                      const SizedBox(height: 2),
                      Text(first, style: theme.textTheme.headlineMedium),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(first.characters.first.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                ),
              ]),
            ),
            _Hero(onReport: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const SubmitReportScreen()))),
            SectionHeader('Your reports',
                actionLabel: 'See all', onAction: onSeeMine),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Expanded(
                    child: SummaryTile(
                        count: mine.length,
                        label: 'Total',
                        color: AppColors.primary)),
                const SizedBox(width: 8),
                Expanded(
                    child: SummaryTile(
                        count: open,
                        label: 'Open',
                        color: AppColors.status(IncidentStatus.submitted))),
                const SizedBox(width: 8),
                Expanded(
                    child: SummaryTile(
                        count: c(IncidentStatus.inProgress),
                        label: 'In progress',
                        color: AppColors.status(IncidentStatus.inProgress))),
                const SizedBox(width: 8),
                Expanded(
                    child: SummaryTile(
                        count: c(IncidentStatus.resolved),
                        label: 'Resolved',
                        color: AppColors.status(IncidentStatus.resolved))),
              ]),
            ),
            SectionHeader('Recent on campus',
                actionLabel: 'See all', onAction: onSeeAll),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Nothing reported yet. Be the first.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted)),
              ),
            for (final i in recent)
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

class _Hero extends StatelessWidget {
  const _Hero({required this.onReport});
  final VoidCallback onReport;

  Widget _ring(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.10), width: 18),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(children: [
        Positioned(right: -30, top: -34, child: _ring(130)),
        Positioned(right: 36, bottom: -56, child: _ring(110)),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('See something that needs fixing?',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(color: Colors.white, fontSize: 22)),
              const SizedBox(height: 8),
              Text('Report it in under a minute and follow it until it is resolved.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8))),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onReport,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size(0, 46),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Report an issue'),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
