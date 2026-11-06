import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/incident.dart';
import '../repositories/incident_repository.dart';
import '../repositories/storage_repository.dart';
import 'auth_provider.dart';

final incidentRepositoryProvider = Provider<IncidentRepository>(
  (ref) => IncidentRepository(
    FirebaseFirestore.instance,
    StorageRepository(),
  ),
);

/// Live list of every incident (real-time Firestore snapshots).
final incidentsStreamProvider = StreamProvider.autoDispose<List<Incident>>(
  (ref) {
    // Re-subscribe when the signed-in user changes.
    ref.watch(authStateProvider);
    return ref.watch(incidentRepositoryProvider).watchAll();
  },
);

final historyProvider =
    StreamProvider.autoDispose.family<List<HistoryEntry>, String>(
  (ref, id) => ref.watch(incidentRepositoryProvider).watchHistory(id),
);

// ---- Filters -----------------------------------------------------------
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<IncidentCategory?>((ref) => null);
final statusFilterProvider = StateProvider<IncidentStatus?>((ref) => null);

/// Applies search + category + status filters. `onlyMine` limits to the
/// current user's own reports.
final filteredIncidentsProvider = Provider.autoDispose
    .family<AsyncValue<List<Incident>>, bool>((ref, onlyMine) {
  final all = ref.watch(incidentsStreamProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final status = ref.watch(statusFilterProvider);
  final uid = ref.watch(authStateProvider).value?.uid;

  return all.whenData((list) => list.where((i) {
        if (onlyMine && i.reporterId != uid) return false;
        if (category != null && i.category != category) return false;
        if (status != null && i.status != status) return false;
        if (query.isNotEmpty) {
          final hay =
              '${i.title} ${i.description} ${i.location}'.toLowerCase();
          if (!hay.contains(query)) return false;
        }
        return true;
      }).toList());
});

// ---- Actions -------------------------------------------------------------
class IncidentController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  IncidentRepository get _repo => ref.read(incidentRepositoryProvider);

  Future<bool> submit({
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    File? image,
  }) {
    final user = ref.read(authRepositoryProvider).currentUser!;
    return _run(() => _repo.create(
          title: title,
          description: description,
          location: location,
          category: category,
          reporterId: user.uid,
          reporterEmail: user.email ?? '',
          image: image,
        ));
  }

  Future<bool> updateStatus(String id, IncidentStatus status, String note) {
    final staff = ref.read(authRepositoryProvider).currentUser!;
    return _run(() => _repo.updateStatus(
        incidentId: id, status: status, staffId: staff.uid, note: note));
  }

  Future<bool> delete(String id) => _run(() => _repo.delete(id));

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final incidentControllerProvider =
    AsyncNotifierProvider.autoDispose<IncidentController, void>(
        IncidentController.new);
