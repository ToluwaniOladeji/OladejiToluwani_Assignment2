import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    debugPrint('Firebase init failed: $e\n$st');
    runApp(MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Firebase failed to start:\n\n$e'),
          ),
        ),
      ),
    ));
    return;
  }
  runApp(const ProviderScope(child: CampusApp()));
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus Incident Reporter',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const AuthGate(),
  );
}