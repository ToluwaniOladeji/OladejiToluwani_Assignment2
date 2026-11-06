import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance),
);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// Bumped after email verification so AuthGate re-reads `emailVerified`
/// (authStateChanges does not fire when a user verifies their email).
final authRefreshProvider = StateProvider<int>((ref) => 0);

/// "student" or "staff", read from users/{uid}.
final userRoleProvider = FutureProvider.autoDispose<String>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 'student';
  return ref.watch(authRepositoryProvider).fetchRole(user.uid);
});

final isStaffProvider = Provider.autoDispose<bool>(
  (ref) => ref.watch(userRoleProvider).value == 'staff',
);

/// Handles login / register / verification actions and exposes loading+error.
class AuthController extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> login(String email, String password) =>
      _run(() => _repo.login(email, password));

  Future<bool> register(String name, String email, String password) =>
      _run(() => _repo.register(name, email, password));

  Future<bool> resendVerification() => _run(_repo.resendVerification);

  Future<bool> checkVerified() async {
    state = const AsyncLoading();
    var verified = false;
    state = await AsyncValue.guard(() async {
      verified = await _repo.refreshVerification();
    });
    ref.read(authRefreshProvider.notifier).state++;
    return verified;
  }


  Future<void> logout() => _repo.logout();

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);
