import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/error_messages.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final email = ref.watch(authRepositoryProvider).currentUser?.email ?? '';
    final loading = ref.watch(authControllerProvider).isLoading;
    final ctrl = ref.read(authControllerProvider.notifier);

    void toast(String m) =>
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: ctrl.logout, child: const Text('Log out')),
              ),
              const Spacer(),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    color: AppColors.primary, size: 30),
              ),
              const SizedBox(height: 24),
              Text('Check your inbox', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 10),
              Text('We sent a confirmation link to $email. Open it, then come back here.',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final verified = await ctrl.checkVerified();
                          if (!verified) toast('Email not verified yet.');
                        },
                  child: const Text("I've confirmed my email"),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final ok = await ctrl.resendVerification();
                          final err = ref.read(authControllerProvider).error;
                          toast(ok
                              ? 'Verification email sent.'
                              : errorMessage(err!));
                        },
                  child: const Text('Resend email'),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
