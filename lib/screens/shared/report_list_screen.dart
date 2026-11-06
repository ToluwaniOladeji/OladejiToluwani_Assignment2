import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/page_header.dart';
import 'report_detail_screen.dart';

/// Browse / search / filter. Filter choices are view-only state, so each tab
/// keeps its own copy locally; the incident data itself comes from Riverpod.
class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.onlyMine = false,
  });

  final String title;
  final String subtitle;
  final bool onlyMine;

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  String _query = '';
  IncidentCategory? _category;
  IncidentStatus? _status;

  List<Incident> _apply(List<Incident> all, String? uid) {
    final q = _query.trim().toLowerCase();
    return all.where((i) {
      if (widget.onlyMine && i.reporterId != uid) return false;
      if (_category != null && i.category != _category) return false;
      if (_status != null && i.status != _status) return false;
      if (q.isNotEmpty &&
          !'${i.title} ${i.description} ${i.location}'
              .toLowerCase()
              .contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  Widget _pillRow(List<Widget> pills) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: pills.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => pills[i],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final async = ref.watch(incidentsStreamProvider);
    final filtering = _query.isNotEmpty || _category != null || _status != null;

    return Column(
      children: [
        PageHeader(widget.title, subtitle: widget.subtitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search title, description or place',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _pillRow([
          FilterPill(
              label: 'All',
              selected: _status == null,
              onTap: () => setState(() => _status = null)),
          for (final s in IncidentStatus.values)
            FilterPill(
                label: s.label,
                selected: _status == s,
                onTap: () =>
                    setState(() => _status = _status == s ? null : s)),
        ]),
        const SizedBox(height: 8),
        _pillRow([
          FilterPill(
              label: 'Any category',
              selected: _category == null,
              onTap: () => setState(() => _category = null)),
          for (final c in IncidentCategory.values)
            FilterPill(
                label: c.label,
                icon: c.icon,
                selected: _category == c,
                onTap: () =>
                    setState(() => _category = _category == c ? null : c)),
        ]),
        const SizedBox(height: 8),
        Expanded(
          child: AsyncValueView<List<Incident>>(
            value: async,
            onRetry: () => ref.invalidate(incidentsStreamProvider),
            data: (all) {
              final list = _apply(all, uid);
              if (list.isEmpty) {
                return EmptyState(
                  icon: filtering
                      ? Icons.search_off_rounded
                      : Icons.inbox_outlined,
                  message: filtering
                      ? 'No reports match your search or filters.'
                      : (widget.onlyMine
                          ? "You haven't reported anything yet.\nTap + to file your first report."
                          : 'No reports yet.'),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 24, top: 4),
                itemCount: list.length,
                itemBuilder: (_, i) => IncidentCard(
                  incident: list[i],
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          ReportDetailScreen(incidentId: list[i].id))),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
