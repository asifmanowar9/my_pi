enum AssessmentType {
  quiz,
  midterm,
  final_exam,
  assignment,
  project,
  presentation,
  lab,
  participation,
  other,
}

class Grade {
  final String id;
  final String courseId;
  final AssessmentType assessmentType;
  final double marks;
  final double totalMarks;
  final double weight;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? lastSyncAt;

  const Grade({
    required this.id,
    required this.courseId,
    required this.assessmentType,
    required this.marks,
    required this.totalMarks,
    required this.weight,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lastSyncAt,
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'assessmentType': assessmentType.name,
      'marks': marks,
      'totalMarks': totalMarks,
      'weight': weight,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  // fromJson method
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      assessmentType: AssessmentType.values.firstWhere(
        (e) => e.name == json['assessmentType'],
        orElse: () => AssessmentType.other,
      ),
      marks: (json['marks'] as num).toDouble(),
      totalMarks: (json['totalMarks'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
    );
  }

  // copyWith method
  Grade copyWith({
    String? id,
    String? courseId,
    AssessmentType? assessmentType,
    double? marks,
    double? totalMarks,
    double? weight,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? lastSyncAt,
  }) {
    return Grade(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      assessmentType: assessmentType ?? this.assessmentType,
      marks: marks ?? this.marks,
      totalMarks: totalMarks ?? this.totalMarks,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty &&
        courseId.isNotEmpty &&
        marks >= 0 &&
        totalMarks > 0 &&
        weight >= 0 &&
        weight <= 100 &&
        marks <= totalMarks;
  }

  String? validateCourseId() {
    if (courseId.isEmpty) return 'Course ID is required';
    return null;
  }

  String? validateMarks() {
    if (marks < 0) return 'Marks cannot be negative';
    if (marks > totalMarks) return 'Marks cannot exceed total marks';
    return null;
  }

  String? validateTotalMarks() {
    if (totalMarks <= 0) return 'Total marks must be greater than 0';
    if (totalMarks > 1000) return 'Total marks seems too high';
    return null;
  }

  String? validateWeight() {
    if (weight < 0) return 'Weight cannot be negative';
    if (weight > 100) return 'Weight cannot exceed 100%';
    return null;
  }

  String? validateDate() {
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return 'Grade date cannot be in the future';
    }
    return null;
  }

  // Business logic
  bool needsSync() {
    return !isSynced || (lastSyncAt != null && updatedAt.isAfter(lastSyncAt!));
  }

  Grade markAsSynced() {
    return copyWith(isSynced: true, lastSyncAt: DateTime.now());
  }

  Grade markAsModified() {
    return copyWith(updatedAt: DateTime.now(), isSynced: false);
  }

  double get percentage {
    if (totalMarks == 0) return 0;
    return (marks / totalMarks) * 100;
  }

  String get letterGrade {
    final percent = percentage;
    if (percent >= 90) return 'A+';
    if (percent >= 85) return 'A';
    if (percent >= 80) return 'A-';
    if (percent >= 77) return 'B+';
    if (percent >= 73) return 'B';
    if (percent >= 70) return 'B-';
    if (percent >= 67) return 'C+';
    if (percent >= 63) return 'C';
    if (percent >= 60) return 'C-';
    if (percent >= 57) return 'D+';
    if (percent >= 53) return 'D';
    if (percent >= 50) return 'D-';
    return 'F';
  }

  String get gradeStatus {
    final percent = percentage;
    if (percent >= 90) return 'Excellent';
    if (percent >= 80) return 'Very Good';
    if (percent >= 70) return 'Good';
    if (percent >= 60) return 'Satisfactory';
    if (percent >= 50) return 'Pass';
    return 'Fail';
  }

  bool get isPassing {
    return percentage >= 50;
  }

  double get weightedScore {
    return percentage * (weight / 100);
  }

  String get formattedMarks {
    return '${marks.toStringAsFixed(marks.truncateToDouble() == marks ? 0 : 1)}/${totalMarks.toStringAsFixed(totalMarks.truncateToDouble() == totalMarks ? 0 : 1)}';
  }

  String get formattedPercentage {
    return '${percentage.toStringAsFixed(1)}%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grade && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Grade(id: $id, assessmentType: ${assessmentType.name}, marks: $formattedMarks, percentage: $formattedPercentage)';
  }
}
