import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scholr/app/app.dart';
import 'package:scholr/firebase_options.dart';
import 'package:scholr/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught async error: $error\n$stack');
    return true;
  };
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    debugPrint('Scholr: Firebase.initializeApp failed: $e\n$st');
    runApp(_BootstrapFailureApp(message: '$e'));
    return;
  }
  try {
    await NotificationService().initialize();
  } catch (e, st) {
    debugPrint('Scholr: NotificationService init failed (continuing): $e\n$st');
  }
  runApp(const ScholrApp());
}

class _BootstrapFailureApp extends StatelessWidget {
  const _BootstrapFailureApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scholr cannot start', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                  'Firebase failed to initialize. If you changed projects, run:\n'
                  'dart pub global run flutterfire_cli:flutterfire configure',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(message, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
