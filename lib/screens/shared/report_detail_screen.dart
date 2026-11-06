import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/enums.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_messages.dart';
import '../../widgets/app_card.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/filter_pill.dart';
import '../../widgets/status_chip.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.incidentId});
  final String incidentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(incidentsStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: AsyncValueView<List<Incident>>(
        value: async,
        data: (list) {
          Incident? incident;
          for (final i in list) {
            if (i.id == incidentId) incident = i;
          }
          if (incident == null) {
            return const Center(child: Text('This report no longer exists.'));
          }
          return _DetailBody(incident: incident);
        },
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isStaff = ref.watch(isStaffProvider);
    final uid = ref.watch(authStateProvider).value?.uid;
    final canDelete = isStaff ||
        (incident.reporterId == uid &&
            incident.status == IncidentStatus.submitted);
    final fmt = DateFormat.yMMMd().add_jm();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        if (incident.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              incident.imageUrl!,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, p) => p == null
                  ? child
                  : Container(
                      height: 210,
                      color: AppColors.primarySoft,
                      child: const Center(child: CircularProgressIndicator())),
              errorBuilder: (_, __, ___) => Container(
                  height: 210,
                  color: AppColors.primarySoft,
                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 40))),
            ),
          ),
          const SizedBox(height: 18),
        ],
        Text(incident.category.label.toUpperCase(),
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(incident.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 10),
        Align(alignment: Alignment.centerLeft, child: StatusChip(incident.status)),
        const SizedBox(height: 18),
        AppCard(
          child: Column(children: [
            _InfoRow(Icons.place_outlined, 'Location', incident.location),
            const Divider(height: 20),
            _InfoRow(Icons.schedule, 'Reported', fmt.format(incident.createdAt)),
            if (isStaff) ...[
              const Divider(height: 20),
              _InfoRow(Icons.person_outline, 'Reporter', incident.reporterEmail),
            ],
          ]),
        ),
        const SizedBox(height: 20),
        Text('Details', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(incident.description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        const SizedBox(height: 28),
        Text('Progress', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _ProgressBar(status: incident.status),
        const SizedBox(height: 18),
        _Timeline(incident: incident),
        if (isStaff) ...[
          const SizedBox(height: 28),
          _StaffPanel(incident: incident),
        ],
        if (canDelete) ...[
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              icon: const Icon(Icons.delete_outline),
              label: Text(isStaff ? 'Delete report' : 'Withdraw report'),
              onPressed: () => _confirmDelete(context, ref),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (yes != true) return;
    final ok = await ref.read(incidentControllerProvider.notifier).delete(incident.id);
    if (!context.mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      final err = ref.read(incidentControllerProvider).error!;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage(err))));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ]);
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.status});
  final IncidentStatus status;

  @override
  Widget build(BuildContext context) {
    final idx = IncidentStatus.values.indexOf(status);
    final total = IncidentStatus.values.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          for (var i = 0; i < total; i++)
            Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i <= idx ? AppColors.status(status) : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        Text('Stage ${idx + 1} of $total  ·  ${status.label}',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({required this.incident});
  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider(incident.id));
    final fmt = DateFormat.MMMd().add_jm();
    return AsyncValueView<List<HistoryEntry>>(
      value: history,
      data: (entries) {
        final rows = <Widget>[
          _TimelineTile(
            color: AppColors.status(IncidentStatus.submitted),
            title: 'Report submitted',
            subtitle: fmt.format(incident.createdAt),
            isLast: entries.isEmpty,
          ),
          for (var i = 0; i < entries.length; i++)
            _TimelineTile(
              color: AppColors.status(entries[i].status),
              title: entries[i].status.label,
              subtitle: entries[i].note.isEmpty
                  ? fmt.format(entries[i].changedAt)
                  : '${entries[i].note}\n${fmt.format(entries[i].changedAt)}',
              isLast: i == entries.length - 1,
            ),
        ];
        return Column(children: rows);
      },
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });
  final Color color;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 24,
            child: Column(children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ]),
      );
}

/// Only rendered for staff. Firestore rules enforce this server-side too.
class _StaffPanel extends ConsumerStatefulWidget {
  const _StaffPanel({required this.incident});
  final Incident incident;
  @override
  ConsumerState<_StaffPanel> createState() => _StaffPanelState();
}

class _StaffPanelState extends ConsumerState<_StaffPanel> {
  late IncidentStatus _status = widget.incident.status;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final ok = await ref
        .read(incidentControllerProvider.notifier)
        .updateStatus(widget.incident.id, _status, _note.text);
    if (!mounted) return;
    final msg = ok
        ? 'Status updated'
        : errorMessage(ref.read(incidentControllerProvider).error!);
    if (ok) _note.clear();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = ref.watch(incidentControllerProvider).isLoading;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Update status', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Visible to campus staff only', style: theme.textTheme.bodySmall),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final s in IncidentStatus.values)
              FilterPill(
                label: s.label,
                selected: _status == s,
                onTap: () => setState(() => _status = s),
              ),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
                labelText: 'Note for the reporter (optional)'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed:
                  loading || _status == widget.incident.status ? null : _update,
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save update'),
            ),
          ),
        ],
      ),
    );
  }
}
