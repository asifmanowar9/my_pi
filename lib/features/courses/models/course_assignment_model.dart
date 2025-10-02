class CourseAssignmentModel {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool isCompleted;
  final double? grade; // Actual grade received
  final double? maxGrade; // Maximum possible grade
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseAssignmentModel({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.dueDate,
    this.isCompleted = false,
    this.grade,
    this.maxGrade,
    required this.createdAt,
    required this.updatedAt,
  });

  // Check if assignment is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Check if assignment has a grade
  bool get hasGrade => grade != null;

  // Calculate grade percentage
  double? get gradePercentage {
    if (grade == null || maxGrade == null || maxGrade == 0) return null;
    return (grade! / maxGrade!) * 100;
  }

  // Get grade status (A, B, C, etc.)
  String? get gradeStatus {
    final percentage = gradePercentage;
    if (percentage == null) return null;

    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  // Get days until due
  int? get daysUntilDue {
    if (dueDate == null) return null;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference;
  }

  // Factory constructor from JSON
  factory CourseAssignmentModel.fromJson(Map<String, dynamic> json) {
    return CourseAssignmentModel(
      id: json['id'] as String? ?? '',
      courseId: json['course_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Assignment',
      description: json['description'] as String?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      isCompleted: (json['is_completed'] as int?) == 1,
      grade: json['grade'] != null ? (json['grade'] as num).toDouble() : null,
      maxGrade: json['max_grade'] != null
          ? (json['max_grade'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'grade': grade,
      'max_grade': maxGrade,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  CourseAssignmentModel copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    double? grade,
    double? maxGrade,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseAssignmentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      grade: grade ?? this.grade,
      maxGrade: maxGrade ?? this.maxGrade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Validation
  bool isValid() {
    return title.trim().isNotEmpty && courseId.trim().isNotEmpty;
  }

  List<String> validate() {
    final errors = <String>[];

    if (title.trim().isEmpty) {
      errors.add('Assignment title is required');
    }

    if (courseId.trim().isEmpty) {
      errors.add('Course ID is required');
    }

    if (grade != null && maxGrade != null && grade! > maxGrade!) {
      errors.add('Grade cannot exceed maximum grade');
    }

    if (grade != null && grade! < 0) {
      errors.add('Grade cannot be negative');
    }

    if (maxGrade != null && maxGrade! <= 0) {
      errors.add('Maximum grade must be greater than 0');
    }

    return errors;
  }

  @override
  String toString() {
    return 'CourseAssignmentModel(id: $id, title: $title, courseId: $courseId, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseAssignmentModel &&
        other.id == id &&
        other.courseId == courseId &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ courseId.hashCode ^ title.hashCode;
  }
}
