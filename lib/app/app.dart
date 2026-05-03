import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/providers/room_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/services/auth_service.dart';
import 'package:scholr/services/firestore_service.dart';
import 'package:scholr/services/notification_service.dart';
import 'package:scholr/services/storage_service.dart';
import 'package:scholr/theme/app_theme.dart';

class ScholrApp extends StatelessWidget {
  const ScholrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => NotificationService()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
            context.read<NotificationService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => TaskProvider(context.read<FirestoreService>(), context.read<NotificationService>())),
        ChangeNotifierProvider(create: (context) => GroupProvider(context.read<FirestoreService>())),
        ChangeNotifierProvider(create: (context) => RoomProvider(context.read<FirestoreService>())),
      ],
      child: const _ScholrMaterialApp(),
    );
  }
}

/// [GoRouter] must be created once. [createRouter] already passes [AuthProvider]
/// as [GoRouter.refreshListenable], so redirects update without rebuilding the router.
class _ScholrMaterialApp extends StatefulWidget {
  const _ScholrMaterialApp();

  @override
  State<_ScholrMaterialApp> createState() => _ScholrMaterialAppState();
}

class _ScholrMaterialAppState extends State<_ScholrMaterialApp> {
  GoRouter? _router;

  @override
  Widget build(BuildContext context) {
    _router ??= createRouter(context.read<AuthProvider>());
    return MaterialApp.router(
      title: 'Scholr',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router!,
    );
  }
}
