class CourseGradeModel {
  final String id;
  final String courseId;
  final List<double> quizMarks; // 2-4 quizzes
  final List<double> quizMaxMarks;
  final double? labReportMark;
  final double? labReportMaxMark;
  final double? midtermMark;
  final double? midtermMaxMark;
  final double? presentationMark;
  final double? presentationMaxMark;
  final double? finalExamMark;
  final double? finalExamMaxMark;
  final List<double> assignmentMarks;
  final List<double> assignmentMaxMarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Grade weights (percentages)
  final double quizWeight;
  final double labReportWeight;
  final double midtermWeight;
  final double presentationWeight;
  final double finalExamWeight;
  final double assignmentWeight;

  CourseGradeModel({
    required this.id,
    required this.courseId,
    this.quizMarks = const [],
    this.quizMaxMarks = const [],
    this.labReportMark,
    this.labReportMaxMark,
    this.midtermMark,
    this.midtermMaxMark,
    this.presentationMark,
    this.presentationMaxMark,
    this.finalExamMark,
    this.finalExamMaxMark,
    this.assignmentMarks = const [],
    this.assignmentMaxMarks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.quizWeight = 10.0,
    this.labReportWeight = 10.0,
    this.midtermWeight = 25.0,
    this.presentationWeight = 5.0,
    this.finalExamWeight = 35.0,
    this.assignmentWeight = 15.0,
  });

  // Calculate average quiz percentage
  double? get averageQuizPercentage {
    if (quizMarks.isEmpty || quizMaxMarks.isEmpty) return null;
    if (quizMarks.length != quizMaxMarks.length) return null;

    double totalPercentage = 0;
    for (int i = 0; i < quizMarks.length; i++) {
      if (quizMaxMarks[i] > 0) {
        totalPercentage += (quizMarks[i] / quizMaxMarks[i]) * 100;
      }
    }
    return totalPercentage / quizMarks.length;
  }

  // Calculate lab report percentage
  double? get labReportPercentage {
    if (labReportMark == null ||
        labReportMaxMark == null ||
        labReportMaxMark == 0) {
      return null;
    }
    return (labReportMark! / labReportMaxMark!) * 100;
  }

  // Calculate midterm percentage
  double? get midtermPercentage {
    if (midtermMark == null || midtermMaxMark == null || midtermMaxMark == 0) {
      return null;
    }
    return (midtermMark! / midtermMaxMark!) * 100;
  }

  // Calculate presentation percentage
  double? get presentationPercentage {
    if (presentationMark == null ||
        presentationMaxMark == null ||
        presentationMaxMark == 0) {
      return null;
    }
    return (presentationMark! / presentationMaxMark!) * 100;
  }

  // Calculate final exam percentage
  double? get finalExamPercentage {
    if (finalExamMark == null ||
        finalExamMaxMark == null ||
        finalExamMaxMark == 0) {
      return null;
    }
    return (finalExamMark! / finalExamMaxMark!) * 100;
  }

  // Calculate average assignment percentage
  double? get averageAssignmentPercentage {
    if (assignmentMarks.isEmpty || assignmentMaxMarks.isEmpty) return null;
    if (assignmentMarks.length != assignmentMaxMarks.length) return null;

    double totalPercentage = 0;
    for (int i = 0; i < assignmentMarks.length; i++) {
      if (assignmentMaxMarks[i] > 0) {
        totalPercentage += (assignmentMarks[i] / assignmentMaxMarks[i]) * 100;
      }
    }
    return totalPercentage / assignmentMarks.length;
  }

  // Calculate total weighted percentage
  double get totalPercentage {
    double total = 0;
    double totalWeight = 0;

    // Quiz
    if (averageQuizPercentage != null) {
      total += averageQuizPercentage! * (quizWeight / 100);
      totalWeight += quizWeight;
    }

    // Lab Report
    if (labReportPercentage != null) {
      total += labReportPercentage! * (labReportWeight / 100);
      totalWeight += labReportWeight;
    }

    // Midterm
    if (midtermPercentage != null) {
      total += midtermPercentage! * (midtermWeight / 100);
      totalWeight += midtermWeight;
    }

    // Presentation
    if (presentationPercentage != null) {
      total += presentationPercentage! * (presentationWeight / 100);
      totalWeight += presentationWeight;
    }

    // Final Exam
    if (finalExamPercentage != null) {
      total += finalExamPercentage! * (finalExamWeight / 100);
      totalWeight += finalExamWeight;
    }

    // Assignment
    if (averageAssignmentPercentage != null) {
      total += averageAssignmentPercentage! * (assignmentWeight / 100);
      totalWeight += assignmentWeight;
    }

    // If no grades entered, return 0
    if (totalWeight == 0) return 0;

    // Normalize to 100% if not all components are graded yet
    return (total / totalWeight) * 100;
  }

  // Get letter grade based on percentage
  String get letterGrade {
    final percent = totalPercentage;
    if (percent >= 80) return 'A+';
    if (percent >= 75) return 'A';
    if (percent >= 70) return 'A-';
    if (percent >= 65) return 'B+';
    if (percent >= 60) return 'B';
    if (percent >= 55) return 'B-';
    if (percent >= 50) return 'C+';
    if (percent >= 45) return 'C';
    if (percent >= 40) return 'D';
    return 'F';
  }

  // Calculate GPA (4.0 scale)
  double get gpa {
    final percent = totalPercentage;
    if (percent >= 80) return 4.0; // A+
    if (percent >= 75) return 3.75; // A
    if (percent >= 70) return 3.5; // A-
    if (percent >= 65) return 3.25; // B+
    if (percent >= 60) return 3.0; // B
    if (percent >= 55) return 2.75; // B-
    if (percent >= 50) return 2.50; // C+
    if (percent >= 45) return 2.25; // C
    if (percent >= 40) return 2.0; // D
    return 0.0; // F
  }

  // Get grade status
  String get gradeStatus {
    final percent = totalPercentage;
    if (percent >= 80) return 'Excellent';
    if (percent >= 70) return 'Very Good';
    if (percent >= 60) return 'Good';
    if (percent >= 50) return 'Satisfactory';
    if (percent >= 40) return 'Pass';
    return 'Fail';
  }

  // Check if passing
  bool get isPassing => totalPercentage >= 40;

  // Get completion percentage (how many components have grades)
  double get completionPercentage {
    int total = 6; // Total possible components
    int completed = 0;

    if (quizMarks.isNotEmpty) completed++;
    if (labReportMark != null) completed++;
    if (midtermMark != null) completed++;
    if (presentationMark != null) completed++;
    if (finalExamMark != null) completed++;
    if (assignmentMarks.isNotEmpty) completed++;

    return (completed / total) * 100;
  }

  // Factory constructor from JSON
  factory CourseGradeModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse comma-separated doubles
    List<double> _parseDoubleList(String? str) {
      if (str == null || str.isEmpty) return [];
      return str
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .map((e) => double.tryParse(e.trim()) ?? 0.0)
          .toList();
    }

    return CourseGradeModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      quizMarks: _parseDoubleList(json['quiz_marks'] as String?),
      quizMaxMarks: _parseDoubleList(json['quiz_max_marks'] as String?),
      labReportMark: json['lab_report_mark'] as double?,
      labReportMaxMark: json['lab_report_max_mark'] as double?,
      midtermMark: json['midterm_mark'] as double?,
      midtermMaxMark: json['midterm_max_mark'] as double?,
      presentationMark: json['presentation_mark'] as double?,
      presentationMaxMark: json['presentation_max_mark'] as double?,
      finalExamMark: json['final_exam_mark'] as double?,
      finalExamMaxMark: json['final_exam_max_mark'] as double?,
      assignmentMarks: _parseDoubleList(json['assignment_marks'] as String?),
      assignmentMaxMarks: _parseDoubleList(
        json['assignment_max_marks'] as String?,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      quizWeight: json['quiz_weight'] as double? ?? 10.0,
      labReportWeight: json['lab_report_weight'] as double? ?? 10.0,
      midtermWeight: json['midterm_weight'] as double? ?? 25.0,
      presentationWeight: json['presentation_weight'] as double? ?? 5.0,
      finalExamWeight: json['final_exam_weight'] as double? ?? 35.0,
      assignmentWeight: json['assignment_weight'] as double? ?? 15.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'quiz_marks': quizMarks.join(','),
      'quiz_max_marks': quizMaxMarks.join(','),
      'lab_report_mark': labReportMark,
      'lab_report_max_mark': labReportMaxMark,
      'midterm_mark': midtermMark,
      'midterm_max_mark': midtermMaxMark,
      'presentation_mark': presentationMark,
      'presentation_max_mark': presentationMaxMark,
      'final_exam_mark': finalExamMark,
      'final_exam_max_mark': finalExamMaxMark,
      'assignment_marks': assignmentMarks.join(','),
      'assignment_max_marks': assignmentMaxMarks.join(','),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'quiz_weight': quizWeight,
      'lab_report_weight': labReportWeight,
      'midterm_weight': midtermWeight,
      'presentation_weight': presentationWeight,
      'final_exam_weight': finalExamWeight,
      'assignment_weight': assignmentWeight,
    };
  }

  // Create a copy with modified fields
  CourseGradeModel copyWith({
    String? id,
    String? courseId,
    List<double>? quizMarks,
    List<double>? quizMaxMarks,
    double? labReportMark,
    double? labReportMaxMark,
    double? midtermMark,
    double? midtermMaxMark,
    double? presentationMark,
    double? presentationMaxMark,
    double? finalExamMark,
    double? finalExamMaxMark,
    List<double>? assignmentMarks,
    List<double>? assignmentMaxMarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? quizWeight,
    double? labReportWeight,
    double? midtermWeight,
    double? presentationWeight,
    double? finalExamWeight,
    double? assignmentWeight,
  }) {
    return CourseGradeModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      quizMarks: quizMarks ?? this.quizMarks,
      quizMaxMarks: quizMaxMarks ?? this.quizMaxMarks,
      labReportMark: labReportMark ?? this.labReportMark,
      labReportMaxMark: labReportMaxMark ?? this.labReportMaxMark,
      midtermMark: midtermMark ?? this.midtermMark,
      midtermMaxMark: midtermMaxMark ?? this.midtermMaxMark,
      presentationMark: presentationMark ?? this.presentationMark,
      presentationMaxMark: presentationMaxMark ?? this.presentationMaxMark,
      finalExamMark: finalExamMark ?? this.finalExamMark,
      finalExamMaxMark: finalExamMaxMark ?? this.finalExamMaxMark,
      assignmentMarks: assignmentMarks ?? this.assignmentMarks,
      assignmentMaxMarks: assignmentMaxMarks ?? this.assignmentMaxMarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      quizWeight: quizWeight ?? this.quizWeight,
      labReportWeight: labReportWeight ?? this.labReportWeight,
      midtermWeight: midtermWeight ?? this.midtermWeight,
      presentationWeight: presentationWeight ?? this.presentationWeight,
      finalExamWeight: finalExamWeight ?? this.finalExamWeight,
      assignmentWeight: assignmentWeight ?? this.assignmentWeight,
    );
  }

  @override
  String toString() {
    return 'CourseGradeModel(id: $id, courseId: $courseId, grade: $letterGrade, gpa: ${gpa.toStringAsFixed(2)}, percentage: ${totalPercentage.toStringAsFixed(1)}%)';
  }
}
