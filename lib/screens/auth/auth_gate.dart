import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/async_value_view.dart';
import '../home_shell.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

/// Single place that decides what the user sees:
/// logged out -> login, unverified -> verify, verified -> home (by role).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authRefreshProvider); // rebuild after email verification
    final auth = ref.watch(authStateProvider);

    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: AsyncValueView<void>(
          value: AsyncError(e, StackTrace.current), data: (_) => const SizedBox())),
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const VerifyEmailScreen();
        final role = ref.watch(userRoleProvider);
        return role.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
              body: AsyncValueView<void>(
                  value: AsyncError(e, StackTrace.current),
                  data: (_) => const SizedBox(),
                  onRetry: () => ref.invalidate(userRoleProvider))),
          data: (r) => HomeShell(isStaff: r == 'staff'),
        );
      },
    );
  }
}
