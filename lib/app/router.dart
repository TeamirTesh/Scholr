import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/screens/auth/login_screen.dart';
import 'package:scholr/screens/auth/signup_screen.dart';
import 'package:scholr/screens/groups/create_group_screen.dart';
import 'package:scholr/screens/groups/group_detail_screen.dart';
import 'package:scholr/screens/groups/groups_screen.dart';
import 'package:scholr/screens/home/home_screen.dart';
import 'package:scholr/screens/profile/profile_screen.dart';
import 'package:scholr/screens/rooms/rooms_screen.dart';
import 'package:scholr/screens/tasks/add_task_screen.dart';
import 'package:scholr/screens/tasks/tasks_screen.dart';

class AppRoutes {
  static const login = 'login';
  static const signup = 'signup';
  static const home = 'home';
  static const tasks = 'tasks';
  static const addTask = 'add-task';
  static const groups = 'groups';
  static const createGroup = 'create-group';
  static const groupDetail = 'group-detail';
  static const rooms = 'rooms';
  static const profile = 'profile';
}

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final loggedIn = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', name: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/signup', name: AppRoutes.signup, builder: (_, _) => const SignupScreen()),
      GoRoute(path: '/home', name: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/tasks', name: AppRoutes.tasks, builder: (_, _) => const TasksScreen()),
      GoRoute(path: '/tasks/add', name: AppRoutes.addTask, builder: (_, _) => const AddTaskScreen()),
      GoRoute(path: '/groups', name: AppRoutes.groups, builder: (_, _) => const GroupsScreen()),
      GoRoute(path: '/groups/create', name: AppRoutes.createGroup, builder: (_, _) => const CreateGroupScreen()),
      GoRoute(
        path: '/groups/:id',
        name: AppRoutes.groupDetail,
        builder: (_, state) => GroupDetailScreen(groupId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/rooms', name: AppRoutes.rooms, builder: (_, _) => const RoomsScreen()),
      GoRoute(path: '/profile', name: AppRoutes.profile, builder: (_, _) => const ProfileScreen()),
    ],
  );
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
