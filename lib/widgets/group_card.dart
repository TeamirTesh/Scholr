import 'package:flutter/material.dart';
import 'package:scholr/models/group_model.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.group, required this.onTap, this.trailing});
  final GroupModel group;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(group.name),
        subtitle: Text('${group.course} · ${group.members.length} members'),
        trailing: trailing,
      ),
    );
  }
}
