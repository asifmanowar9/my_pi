import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/assessment_model.dart';
import '../controllers/assessment_controller.dart';

class AddAssessmentPage extends StatefulWidget {
  final String courseId;
  final AssessmentModel? assessment; // For editing
  final AssessmentType? preselectedType; // For pre-selecting type when adding

  const AddAssessmentPage({
    Key? key,
    required this.courseId,
    this.assessment,
    this.preselectedType,
  }) : super(key: key);

  @override
  State<AddAssessmentPage> createState() => _AddAssessmentPageState();
}

class _AddAssessmentPageState extends State<AddAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _marksController = TextEditingController();
  final _maxMarksController = TextEditingController();

  AssessmentType _selectedType = AssessmentType.quiz;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  int _reminderMinutes = 60; // Default 1 hour before
  bool _isCompleted = false;

  // Helper to get correct max marks for assignment/presentation
  double _getMaxMarksForType(AssessmentType type) {
    if (type != AssessmentType.assignment &&
        type != AssessmentType.presentation) {
      return type.defaultMaxMarks;
    }

    // For assignment/presentation, check if the other exists
    final controller = Get.find<AssessmentController>();
    final assessments = controller.assessments
        .where((a) => a.courseId == widget.courseId)
        .toList();

    final hasAssignment = assessments.any(
      (a) =>
          a.type == AssessmentType.assignment && a.id != widget.assessment?.id,
    );
    final hasPresentation = assessments.any(
      (a) =>
          a.type == AssessmentType.presentation &&
          a.id != widget.assessment?.id,
    );

    // If adding assignment and presentation exists (or vice versa), max is 10
    if ((type == AssessmentType.assignment && hasPresentation) ||
        (type == AssessmentType.presentation && hasAssignment)) {
      return 10.0;
    }

    // Otherwise, max is 20
    return 20.0;
  }

  @override
  void initState() {
    super.initState();
    if (widget.assessment != null) {
      _titleController.text = widget.assessment!.title;
      _descriptionController.text = widget.assessment!.description ?? '';
      _selectedType = widget.assessment!.type;
      _dueDate = widget.assessment!.dueDate;
      if (_dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(_dueDate!);
      }
      _reminderMinutes = widget.assessment!.reminderMinutes ?? 60;
      _marksController.text = widget.assessment!.marks?.toString() ?? '';
      _maxMarksController.text = widget.assessment!.maxMarks?.toString() ?? '';
      _isCompleted = widget.assessment!.isCompleted;
    } else if (widget.preselectedType != null) {
      // Pre-select the type if provided
      _selectedType = widget.preselectedType!;
      // Set default max marks based on type (checks for assignment/presentation)
      _maxMarksController.text = _getMaxMarksForType(_selectedType).toString();
    } else {
      // Set default max marks for default type (quiz)
      _maxMarksController.text = _getMaxMarksForType(_selectedType).toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _marksController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  DateTime? _getCombinedDateTime() {
    if (_dueDate == null) return null;
    if (_dueTime == null) return _dueDate;

    return DateTime(
      _dueDate!.year,
      _dueDate!.month,
      _dueDate!.day,
      _dueTime!.hour,
      _dueTime!.minute,
    );
  }

  bool _isSaving = false;

  Future<void> _deleteAssessment() async {
    if (widget.assessment == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Assessment'),
        content: Text(
          'Are you sure you want to delete "${widget.assessment!.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = Get.find<AssessmentController>();
      final success = await controller.deleteAssessment(widget.assessment!.id);

      if (success) {
        // Wait briefly for snackbar, then navigate back
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to refresh the list
        }
      } else {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      Get.snackbar(
        'Error',
        'Failed to delete assessment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveAssessment() async {
    if (!_formKey.currentState!.validate()) return;

    // Prevent double submission
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = Get.find<AssessmentController>();
      final combinedDateTime = _getCombinedDateTime();

      final assessment = widget.assessment == null
          ? AssessmentModel.create(
              courseId: widget.courseId,
              type: _selectedType,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              dueDate: combinedDateTime,
              reminderMinutes: combinedDateTime != null
                  ? _reminderMinutes
                  : null,
              marks: _marksController.text.isEmpty
                  ? null
                  : double.tryParse(_marksController.text),
              maxMarks: _maxMarksController.text.isEmpty
                  ? null
                  : double.tryParse(_maxMarksController.text),
            )
          : widget.assessment!.copyWith(
              type: _selectedType,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              dueDate: combinedDateTime,
              reminderMinutes: combinedDateTime != null
                  ? _reminderMinutes
                  : null,
              marks: _marksController.text.isEmpty
                  ? null
                  : double.tryParse(_marksController.text),
              maxMarks: _maxMarksController.text.isEmpty
                  ? null
                  : double.tryParse(_maxMarksController.text),
              isCompleted: _isCompleted,
              updatedAt: DateTime.now(),
            );

      final success = widget.assessment == null
          ? await controller.addAssessment(assessment)
          : await controller.updateAssessment(assessment);

      if (success) {
        // Wait briefly for snackbar, then navigate back
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to refresh the list
        }
      } else {
        // Reset saving state if failed
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.assessment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assessment' : 'Add Assessment'),
        backgroundColor: theme.colorScheme.inversePrimary,
        actions: [
          // Delete button (only when editing)
          if (isEditing && !_isSaving)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAssessment,
              tooltip: 'Delete',
              color: Colors.red[300],
            ),
          // Save button or loading indicator
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAssessment,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Assessment Type Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assessment Type',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AssessmentType.values.map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text('${type.icon} ${type.displayName}'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = type;
                              // Auto-update max marks when type changes (only if empty or was default)
                              if (_maxMarksController.text.isEmpty ||
                                  widget.assessment == null) {
                                _maxMarksController.text = _getMaxMarksForType(
                                  type,
                                ).toString();
                              }
                            });
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due Date and Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Due Date & Time',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _dueDate == null
                                  ? 'Select Date'
                                  : DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(_dueDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _dueTime == null
                                  ? 'Select Time'
                                  : _dueTime!.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Reminder
            if (_dueDate != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _reminderMinutes,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notifications),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 minutes before'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 minutes before'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('1 hour before'),
                          ),
                          DropdownMenuItem(
                            value: 120,
                            child: Text('2 hours before'),
                          ),
                          DropdownMenuItem(
                            value: 1440,
                            child: Text('1 day before'),
                          ),
                          DropdownMenuItem(
                            value: 2880,
                            child: Text('2 days before'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderMinutes = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Marks (Optional)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marks (Optional)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _marksController,
                            decoration: const InputDecoration(
                              labelText: 'Obtained Marks',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('out of'),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _maxMarksController,
                            decoration: const InputDecoration(
                              labelText: 'Maximum Marks',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Completion Status (only for editing)
            if (isEditing) ...[
              SwitchListTile(
                title: const Text('Mark as Completed'),
                value: _isCompleted,
                onChanged: (value) {
                  setState(() => _isCompleted = value);
                },
                secondary: const Icon(Icons.check_circle),
              ),
              const SizedBox(height: 16),
            ],

            // Save Button
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveAssessment,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : (isEditing ? 'Update Assessment' : 'Add Assessment'),
              ),
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
