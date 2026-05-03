import 'package:flutter/material.dart';

const String addNewCourseSentinel = '__scholr_add_course__';

/// Hybrid course dropdown with "+ Add new course..." and inline add flow.
class CoursePickerField extends StatefulWidget {
  const CoursePickerField({
    super.key,
    required this.courses,
    required this.value,
    required this.onChanged,
    required this.onCommitNewCourse,
    this.errorText,
  });

  final List<String> courses;
  final String? value;
  final ValueChanged<String?> onChanged;
  final Future<void> Function(String name) onCommitNewCourse;
  final String? errorText;

  @override
  State<CoursePickerField> createState() => _CoursePickerFieldState();
}

class _CoursePickerFieldState extends State<CoursePickerField> {
  bool _addingNew = false;
  final _newCtrl = TextEditingController();
  bool _addingBusy = false;

  @override
  void dispose() {
    _newCtrl.dispose();
    super.dispose();
  }

  String? get _dropdownValue {
    final v = widget.value;
    if (v != null && widget.courses.contains(v)) return v;
    return null;
  }

  Future<void> _submitNew() async {
    final name = _newCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _addingBusy = true);
    try {
      await widget.onCommitNewCourse(name);
      if (!mounted) return;
      widget.onChanged(name);
      setState(() {
        _addingNew = false;
        _newCtrl.clear();
      });
    } finally {
      if (mounted) setState(() => _addingBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[
      ...widget.courses.map((c) => DropdownMenuItem(value: c, child: Text(c))),
      const DropdownMenuItem(value: addNewCourseSentinel, child: Text('+ Add new course...')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          // ignore: deprecated_member_use
          value: _addingNew ? null : _dropdownValue,
          decoration: InputDecoration(labelText: 'Course', errorText: widget.errorText),
          items: items,
          onChanged: (v) {
            if (v == addNewCourseSentinel) {
              setState(() => _addingNew = true);
              widget.onChanged(null);
            } else {
              setState(() => _addingNew = false);
              widget.onChanged(v);
            }
          },
        ),
        if (_addingNew) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _newCtrl,
            decoration: const InputDecoration(labelText: 'New course name'),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitNew(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: _addingBusy
                    ? null
                    : () => setState(() {
                        _addingNew = false;
                        _newCtrl.clear();
                      }),
                child: const Text('Cancel'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _addingBusy ? null : _submitNew,
                child: _addingBusy
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add course'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
