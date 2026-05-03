import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/widgets/main_nav_bar.dart';
import 'package:scholr/widgets/group_card.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid!;
    final provider = context.read<GroupProvider>();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('Groups'), bottom: const TabBar(tabs: [Tab(text: 'My Groups'), Tab(text: 'Discover')])),
        bottomNavigationBar: const MainNavBar(current: 2),
        floatingActionButton: FloatingActionButton(onPressed: () => context.pushNamed(AppRoutes.createGroup), child: const Icon(Icons.add)),
        body: TabBarView(
          children: [
            StreamBuilder(
              stream: provider.myGroups(uid),
              builder: (_, snap) => ListView(
                children: (snap.data ?? [])
                    .map((g) => GroupCard(group: g, onTap: () => context.pushNamed(AppRoutes.groupDetail, pathParameters: {'id': g.id})))
                    .toList(),
              ),
            ),
            StreamBuilder(
              stream: provider.discover(uid),
              builder: (_, snap) => ListView(
                children: (snap.data ?? [])
                    .map(
                      (g) => GroupCard(
                        group: g,
                        onTap: () => context.pushNamed(AppRoutes.groupDetail, pathParameters: {'id': g.id}),
                        trailing: TextButton(onPressed: () => provider.joinGroup(g.id, uid), child: const Text('Join')),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
