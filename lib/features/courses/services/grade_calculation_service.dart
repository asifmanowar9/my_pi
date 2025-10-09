import '../models/assessment_model.dart';

/// Service to calculate GPA based on all assessments
/// New grading system:
/// - Quiz: 15% (best 2 out of 1-4 quizzes, averaged)
/// - Midterm: 20%
/// - Assignment/Presentation: 20% (auto-split if both exist)
/// - Final Exam: 40%
/// - Attendance: 5%
class GradeCalculationService {
  /// Calculate weighted GPA for a course based on all assessments
  static Map<String, dynamic> calculateCourseGrade(
    List<AssessmentModel> assessments,
  ) {
    // Group assessments by type
    final byType = <AssessmentType, List<AssessmentModel>>{};
    for (var assessment in assessments) {
      byType.putIfAbsent(assessment.type, () => []).add(assessment);
    }

    // Calculate marks for each type with new logic
    final typeMarks = <AssessmentType, double>{};
    final typeMaxMarks = <AssessmentType, double>{};

    // 1. Quiz: Best 2 average (15 marks total)
    final quizzes = byType[AssessmentType.quiz] ?? [];
    final gradedQuizzes = quizzes.where((a) => a.isGraded).toList();
    if (gradedQuizzes.isNotEmpty) {
      // Sort by percentage descending and take best 2
      gradedQuizzes.sort((a, b) => b.percentage!.compareTo(a.percentage!));
      final best2 = gradedQuizzes.take(2).toList();

      // Calculate average marks from best 2
      double totalMarks = 0;
      for (var quiz in best2) {
        totalMarks += quiz.marks!;
      }
      final avgMarks = totalMarks / best2.length;

      typeMarks[AssessmentType.quiz] = avgMarks;
      typeMaxMarks[AssessmentType.quiz] = 15.0;
    }

    // 2. Midterm: 20 marks
    final midterms = byType[AssessmentType.midterm] ?? [];
    final gradedMidterms = midterms.where((a) => a.isGraded).toList();
    if (gradedMidterms.isNotEmpty) {
      // Take the first graded midterm
      typeMarks[AssessmentType.midterm] = gradedMidterms.first.marks!;
      typeMaxMarks[AssessmentType.midterm] = 20.0;
    }

    // 3. Assignment/Presentation: 20 marks total (auto-split)
    final assignments = byType[AssessmentType.assignment] ?? [];
    final presentations = byType[AssessmentType.presentation] ?? [];
    final gradedAssignments = assignments.where((a) => a.isGraded).toList();
    final gradedPresentations = presentations.where((a) => a.isGraded).toList();

    double assignmentPresentationMarks = 0;
    double assignmentPresentationMax = 0;

    if (gradedAssignments.isNotEmpty && gradedPresentations.isNotEmpty) {
      // Both exist: each should be out of 10, just sum them up
      final assignmentMarks = gradedAssignments.first.marks!;
      final presentationMarks = gradedPresentations.first.marks!;

      // Direct sum (expecting each to be out of 10)
      assignmentPresentationMarks = assignmentMarks + presentationMarks;
      assignmentPresentationMax = 20.0;
    } else if (gradedAssignments.isNotEmpty) {
      // Only assignment: should be out of 20
      final assignmentMarks = gradedAssignments.first.marks!;
      assignmentPresentationMarks = assignmentMarks;
      assignmentPresentationMax = 20.0;
    } else if (gradedPresentations.isNotEmpty) {
      // Only presentation: should be out of 20
      final presentationMarks = gradedPresentations.first.marks!;
      assignmentPresentationMarks = presentationMarks;
      assignmentPresentationMax = 20.0;
    }

    if (assignmentPresentationMax > 0) {
      typeMarks[AssessmentType.assignment] = assignmentPresentationMarks;
      typeMaxMarks[AssessmentType.assignment] = assignmentPresentationMax;
    }

    // 4. Final Exam: 40 marks
    final finals = byType[AssessmentType.finalExam] ?? [];
    final gradedFinals = finals.where((a) => a.isGraded).toList();
    if (gradedFinals.isNotEmpty) {
      typeMarks[AssessmentType.finalExam] = gradedFinals.first.marks!;
      typeMaxMarks[AssessmentType.finalExam] = 40.0;
    }

    // 5. Attendance: 5 marks (direct input)
    final attendances = byType[AssessmentType.attendance] ?? [];
    final gradedAttendances = attendances.where((a) => a.isGraded).toList();
    if (gradedAttendances.isNotEmpty) {
      typeMarks[AssessmentType.attendance] = gradedAttendances.first.marks!;
      typeMaxMarks[AssessmentType.attendance] = 5.0;
    }

    // Calculate total marks (directly sum all marks obtained)
    double totalMarks = 0;
    double totalMaxMarks = 0;

    for (var entry in typeMarks.entries) {
      totalMarks += entry.value;
      totalMaxMarks += typeMaxMarks[entry.key]!;
    }

    // Use actual marks obtained (out of 100 total) for grading
    // No percentage conversion, just use the marks directly
    final marksObtained = totalMarks; // This is already out of 100
    final percentage = totalMaxMarks > 0
        ? (totalMarks / totalMaxMarks) * 100
        : 0.0;

    // Calculate GPA and letter grade based on marks obtained
    final gpa = _marksToGPA(marksObtained);
    final letterGrade = _marksToLetterGrade(marksObtained);

    return {
      'percentage': percentage,
      'gpa': gpa,
      'letterGrade': letterGrade,
      'totalMarks': totalMarks,
      'totalMaxMarks': totalMaxMarks,
      'byType': typeMarks,
      'maxByType': typeMaxMarks,
      'isPassing': marksObtained >= 40,
      'status': _getStatus(marksObtained),
    };
  }

  /// Convert marks (out of 100) to GPA (4.0 scale)
  static double _marksToGPA(double marks) {
    if (marks >= 80) return 4.0; // A+ (80-100)
    if (marks >= 75) return 3.75; // A (75-79)
    if (marks >= 70) return 3.5; // A- (70-74)
    if (marks >= 65) return 3.25; // B+ (65-69)
    if (marks >= 60) return 3.0; // B (60-64)
    if (marks >= 55) return 2.75; // B- (55-59)
    if (marks >= 50) return 2.5; // C+ (50-54)
    if (marks >= 45) return 2.25; // C (45-49)
    if (marks >= 40) return 2.0; // D (40-44)
    return 0.0; // F (0-39)
  }

  /// Convert marks (out of 100) to letter grade
  static String _marksToLetterGrade(double marks) {
    if (marks >= 80) return 'A+'; // 80-100
    if (marks >= 75) return 'A'; // 75-79
    if (marks >= 70) return 'A-'; // 70-74
    if (marks >= 65) return 'B+'; // 65-69
    if (marks >= 60) return 'B'; // 60-64
    if (marks >= 55) return 'B-'; // 55-59
    if (marks >= 50) return 'C+'; // 50-54
    if (marks >= 45) return 'C'; // 45-49
    if (marks >= 40) return 'D'; // 40-44
    return 'F'; // 0-39
  }

  /// Get status based on marks obtained (out of 100)
  static String _getStatus(double marks) {
    if (marks >= 80) return 'Excellent'; // A+
    if (marks >= 70) return 'Very Good'; // A-, A
    if (marks >= 60) return 'Good'; // B, B+
    if (marks >= 50) return 'Satisfactory'; // C+, B-
    if (marks >= 40) return 'Pass'; // D, C
    return 'Fail'; // F
  }

  /// Get completion percentage (how many assessment types have grades)
  static double getCompletionPercentage(List<AssessmentModel> assessments) {
    final types = AssessmentType.values;
    final gradedTypes = <AssessmentType>{};

    for (var assessment in assessments) {
      if (assessment.isGraded) {
        gradedTypes.add(assessment.type);
      }
    }

    return (gradedTypes.length / types.length) * 100;
  }

  /// Get breakdown by assessment type
  static Map<String, dynamic> getTypeBreakdown(
    List<AssessmentModel> assessments,
    AssessmentType type,
  ) {
    final ofType = assessments.where((a) => a.type == type).toList();
    final graded = ofType.where((a) => a.isGraded).toList();

    if (graded.isEmpty) {
      return {
        'total': ofType.length,
        'graded': 0,
        'percentage': null,
        'weight': type.weight,
      };
    }

    double totalPercentage = 0;
    for (var assessment in graded) {
      totalPercentage += assessment.percentage!;
    }
    final avgPercentage = totalPercentage / graded.length;

    return {
      'total': ofType.length,
      'graded': graded.length,
      'percentage': avgPercentage,
      'weight': type.weight,
      'contribution': (avgPercentage / 100) * type.weight,
    };
  }
}
