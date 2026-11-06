import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/page_header.dart';
import '../../widgets/summary_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
    final isStaff = ref.watch(isStaffProvider);
    final name = (user?.displayName ?? '').trim();
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();
    final all = ref.watch(incidentsStreamProvider).value ?? const [];
    final mine = all.where((i) => i.reporterId == user?.uid).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const PageHeader('Profile'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primarySoft,
                child: Text(initial,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? 'Account' : name,
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isStaff ? 'Campus staff' : 'Student',
                          style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
        if (!isStaff) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(
                  child: SummaryTile(
                      count: mine.length,
                      label: 'Submitted',
                      color: AppColors.primary)),
              const SizedBox(width: 8),
              Expanded(
                  child: SummaryTile(
                      count: mine
                          .where((i) => i.status == IncidentStatus.resolved)
                          .length,
                      label: 'Resolved',
                      color: AppColors.status(IncidentStatus.resolved))),
            ]),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: OutlinedButton.icon(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}
