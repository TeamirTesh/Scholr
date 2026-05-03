import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/app/router.dart';
import 'package:scholr/models/group_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/group_provider.dart';
import 'package:scholr/widgets/course_picker_field.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  String? _course;
  AutovalidateMode _auto = AutovalidateMode.disabled;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateCourse() {
    final c = _course?.trim();
    if (c == null || c.isEmpty) return 'Select or add a course';
    return null;
  }

  Future<void> _create() async {
    setState(() => _auto = AutovalidateMode.onUserInteraction);
    final courseErr = _validateCourse();
    if (!_formKey.currentState!.validate() || courseErr != null) {
      setState(() {});
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);
    final uid = context.read<AuthProvider>().uid!;
    final group = GroupModel(
      id: '',
      name: _name.text.trim(),
      course: _course!.trim(),
      createdBy: uid,
      members: [uid],
      fileUrls: const [],
      description: _desc.text.trim(),
      createdAt: DateTime.now(),
    );
    try {
      final id = await context.read<GroupProvider>().createGroup(group);
      if (!mounted) return;
      _name.clear();
      _desc.clear();
      _course = null;
      context.pop();
      context.pushNamed(AppRoutes.groupDetail, pathParameters: {'id': id});
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseError = _validateCourse();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Create Group'),
        ),
        body: StreamBuilder(
          stream: context.read<AuthProvider>().userStream,
          builder: (_, userSnap) {
            final courses = userSnap.data?.courses ?? const <String>[];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: _auto,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Group name'),
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                    ),
                    const SizedBox(height: 12),
                    CoursePickerField(
                      courses: courses,
                      value: _course,
                      errorText: _auto != AutovalidateMode.disabled ? courseError : null,
                      onChanged: (v) => setState(() => _course = v),
                      onCommitNewCourse: (name) async {
                        final auth = context.read<AuthProvider>();
                        final u = auth.currentUser;
                        if (u == null) return;
                        if (u.courses.contains(name)) return;
                        await auth.updateProfile({'courses': [...u.courses, name]});
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _desc,
                      decoration: const InputDecoration(labelText: 'Description'),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _create,
                      child: _submitting
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
