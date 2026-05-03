import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:scholr/models/task_model.dart';
import 'package:scholr/providers/auth_provider.dart';
import 'package:scholr/providers/task_provider.dart';
import 'package:scholr/utils/date_formatters.dart';
import 'package:scholr/widgets/course_picker_field.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _effort = TextEditingController();
  String? _course;
  double _weight = 0.5;
  DateTime? _deadline;
  AutovalidateMode _auto = AutovalidateMode.disabled;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _effort.text = '2';
  }

  @override
  void dispose() {
    _title.dispose();
    _effort.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDate: _deadline ?? now.add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now().add(const Duration(hours: 1))),
    );
    if (time == null || !mounted) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String? _validateTitle(String? v) {
    final t = v?.trim() ?? '';
    if (t.length < 3) return 'Title must be at least 3 characters';
    return null;
  }

  String? _validateCourse() {
    final c = _course?.trim();
    if (c == null || c.isEmpty) return 'Select or add a course';
    return null;
  }

  String? _validateDeadline() {
    if (_deadline == null) return 'Pick a date and time';
    if (!_deadline!.isAfter(DateTime.now())) return 'Deadline must be in the future';
    return null;
  }

  String? _validateEffort(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null || n <= 0) return 'Enter hours greater than 0';
    return null;
  }

  Future<void> _save() async {
    setState(() => _auto = AutovalidateMode.onUserInteraction);
    final courseErr = _validateCourse();
    final deadlineErr = _validateDeadline();
    if (!_formKey.currentState!.validate() || courseErr != null || deadlineErr != null) {
      if (courseErr != null || deadlineErr != null) {
        setState(() {});
      }
      return;
    }
    if (_submitting) return;
    setState(() => _submitting = true);
    final uid = context.read<AuthProvider>().uid!;
    final task = TaskModel(
      id: '',
      userId: uid,
      title: _title.text.trim(),
      course: _course!.trim(),
      courseWeight: _weight,
      deadline: _deadline!,
      estimatedEffortHours: double.parse(_effort.text.trim()),
      status: 'pending',
      createdAt: DateTime.now(),
    );
    try {
      await context.read<TaskProvider>().addTask(task);
      if (!mounted) return;
      _title.clear();
      _effort.text = '2';
      _course = null;
      _deadline = null;
      _weight = 0.5;
      _formKey.currentState!.reset();
      setState(() => _auto = AutovalidateMode.disabled);
      context.pop(true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseError = _validateCourse();
    final deadlineError = _validateDeadline();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          title: const Text('Add Task'),
        ),
        body: StreamBuilder(
          stream: context.read<AuthProvider>().userStream,
          builder: (_, userSnap) {
            final user = userSnap.data;
            final courses = user?.courses ?? const <String>[];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                autovalidateMode: _auto,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'Task title'),
                      textCapitalization: TextCapitalization.sentences,
                      validator: _validateTitle,
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
                    Text('Course weight (${_weight.toStringAsFixed(2)})'),
                    Slider(value: _weight, min: 0, max: 1, divisions: 20, onChanged: (v) => setState(() => _weight = v)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _effort,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Estimated effort (hours)'),
                      validator: _validateEffort,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deadline'),
                      subtitle: Text(
                        _deadline == null ? 'Tap to choose date and time' : scholrDeadlineFormat.format(_deadline!),
                      ),
                      trailing: const Icon(Icons.event),
                      onTap: _pickDeadline,
                    ),
                    if (_auto != AutovalidateMode.disabled && deadlineError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(deadlineError, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _save,
                      child: _submitting
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save task'),
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
