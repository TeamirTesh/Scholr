import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scholr/app/router.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({super.key, required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: (i) {
        final routes = [AppRoutes.home, AppRoutes.tasks, AppRoutes.groups, AppRoutes.rooms, AppRoutes.profile];
        context.goNamed(routes[i]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Tasks'),
        NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'Groups'),
        NavigationDestination(icon: Icon(Icons.meeting_room_outlined), selectedIcon: Icon(Icons.meeting_room), label: 'Rooms'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
