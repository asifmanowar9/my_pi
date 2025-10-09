import 'package:uuid/uuid.dart';

/// Unified model for all types of assessments in a course
/// Includes: Quiz, Midterm, Assignment, Presentation, Final Exam, Attendance
class AssessmentModel {
  final String id;
  final String courseId;
  final AssessmentType type;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int?
  reminderMinutes; // Reminder before due date (e.g., 60, 120, 1440 for 1 day)
  final double? marks; // Obtained marks
  final double? maxMarks; // Maximum marks
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  AssessmentModel({
    required this.id,
    required this.courseId,
    required this.type,
    required this.title,
    this.description,
    this.dueDate,
    this.reminderMinutes,
    this.marks,
    this.maxMarks,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssessmentModel.create({
    required String courseId,
    required AssessmentType type,
    required String title,
    String? description,
    DateTime? dueDate,
    int? reminderMinutes,
    double? marks,
    double? maxMarks,
  }) {
    final now = DateTime.now();
    return AssessmentModel(
      id: const Uuid().v4(),
      courseId: courseId,
      type: type,
      title: title,
      description: description,
      dueDate: dueDate,
      reminderMinutes: reminderMinutes,
      marks: marks,
      maxMarks: maxMarks,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Calculate percentage
  double? get percentage {
    if (marks == null || maxMarks == null || maxMarks! <= 0) return null;
    return (marks! / maxMarks!) * 100;
  }

  // Check if graded
  bool get isGraded => marks != null && maxMarks != null;

  // Check if overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now()).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'type': type.name,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'reminder_minutes': reminderMinutes,
      'marks': marks,
      'max_marks': maxMarks,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AssessmentModel.fromMap(Map<String, dynamic> map) {
    return AssessmentModel(
      id: map['id'] as String,
      courseId: map['course_id'] as String,
      type: AssessmentType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AssessmentType.assignment,
      ),
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      reminderMinutes: map['reminder_minutes'] as int?,
      marks: map['marks'] as double?,
      maxMarks: map['max_marks'] as double?,
      isCompleted: (map['is_completed'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  AssessmentModel copyWith({
    String? id,
    String? courseId,
    AssessmentType? type,
    String? title,
    String? description,
    DateTime? dueDate,
    int? reminderMinutes,
    double? marks,
    double? maxMarks,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssessmentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      marks: marks ?? this.marks,
      maxMarks: maxMarks ?? this.maxMarks,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AssessmentType {
  quiz,
  midterm,
  assignment,
  presentation,
  finalExam,
  attendance,
}

extension AssessmentTypeExtension on AssessmentType {
  String get displayName {
    switch (this) {
      case AssessmentType.quiz:
        return 'Quiz';
      case AssessmentType.midterm:
        return 'Midterm Exam';
      case AssessmentType.assignment:
        return 'Assignment';
      case AssessmentType.presentation:
        return 'Presentation';
      case AssessmentType.finalExam:
        return 'Final Exam';
      case AssessmentType.attendance:
        return 'Attendance';
    }
  }

  String get icon {
    switch (this) {
      case AssessmentType.quiz:
        return '📝';
      case AssessmentType.midterm:
        return '�';
      case AssessmentType.assignment:
        return '✍️';
      case AssessmentType.presentation:
        return '🎤';
      case AssessmentType.finalExam:
        return '📖';
      case AssessmentType.attendance:
        return '✅';
    }
  }

  // Default max marks for each assessment type
  double get defaultMaxMarks {
    switch (this) {
      case AssessmentType.quiz:
        return 15.0; // Each quiz is out of 15
      case AssessmentType.midterm:
        return 20.0; // Midterm is out of 20
      case AssessmentType.assignment:
        return 20.0; // Assignment is out of 20
      case AssessmentType.presentation:
        return 20.0; // Presentation is out of 20
      case AssessmentType.finalExam:
        return 40.0; // Final exam is out of 40
      case AssessmentType.attendance:
        return 5.0; // Attendance is out of 5
    }
  }

  // Weight in final grade calculation
  double get weight {
    switch (this) {
      case AssessmentType.quiz:
        return 15.0; // 15% (best 2 average)
      case AssessmentType.midterm:
        return 20.0; // 20%
      case AssessmentType.assignment:
        return 20.0; // 20% total (split with presentation if exists)
      case AssessmentType.presentation:
        return 20.0; // 20% total (split with assignment if exists)
      case AssessmentType.finalExam:
        return 40.0; // 40%
      case AssessmentType.attendance:
        return 5.0; // 5%
    }
  }
}
