import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../courses/models/course_model.dart';
import '../../courses/models/course_grade_model.dart';
import '../../courses/controllers/course_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/database/database_helper_clean.dart'
    as DatabaseHelperClean;

class TranscriptController extends GetxController {
  final RxList<String> selectedCourses = <String>[].obs;
  final RxBool isGenerating = false.obs;

  void toggleCourseSelection(String courseId, bool selected) {
    if (selected) {
      if (!selectedCourses.contains(courseId)) {
        selectedCourses.add(courseId);
      }
    } else {
      selectedCourses.remove(courseId);
    }
  }

  void selectAll(List<CourseModel> courses) {
    selectedCourses.clear();
    selectedCourses.addAll(courses.map((c) => c.id.toString()));
  }

  void clearSelection() {
    selectedCourses.clear();
  }

  Future<void> generateFullTranscript() async {
    try {
      isGenerating.value = true;
      final courseController = Get.find<CourseController>();
      final courses = courseController.courses;

      await _generateTranscript(courses, 'Full_Academic_Transcript');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate transcript: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> generateCompletedTranscript() async {
    try {
      isGenerating.value = true;
      final courseController = Get.find<CourseController>();
      final completedCourses = courseController.courses
          .where((course) => course.status == 'completed')
          .toList();

      if (completedCourses.isEmpty) {
        Get.snackbar(
          'No Completed Courses',
          'You have no completed courses to include in the transcript.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _generateTranscript(
        completedCourses,
        'Completed_Courses_Transcript',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate transcript: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> generateSelectedTranscript() async {
    if (selectedCourses.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select at least one course to generate a report.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isGenerating.value = true;
      final courseController = Get.find<CourseController>();
      final selectedCourseModels = courseController.courses
          .where((course) => selectedCourses.contains(course.id.toString()))
          .toList();

      await _generateTranscript(
        selectedCourseModels,
        'Selected_Courses_Report',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate report: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> _generateTranscript(
    List<CourseModel> courses,
    String filename,
  ) async {
    final pdf = pw.Document();
    final authController = Get.find<AuthController>();
    final user = authController.user;

    // Pre-fetch all grades for courses
    Map<String, CourseGradeModel?> courseGrades = {};
    for (final course in courses) {
      try {
        final gradeData = await DatabaseHelperClean.DatabaseHelper()
            .getCourseGrade(course.id);
        if (gradeData != null) {
          courseGrades[course.id] = CourseGradeModel.fromJson(gradeData);
        }
      } catch (e) {
        print('Error getting grade for course ${course.id}: $e');
        courseGrades[course.id] = null;
      }
    }

    // Calculate statistics
    final totalCredits = courses.fold<double>(
      0,
      (sum, course) => sum + course.credits,
    );
    final completedCourses = courses
        .where((c) => c.status == 'completed')
        .toList();

    // Calculate GPA
    double totalGradePoints = 0.0;
    double totalGradeCredits = 0.0;

    for (final course in completedCourses) {
      final gradeModel = courseGrades[course.id];
      if (gradeModel != null) {
        final gradePoints = _getGradePoints(gradeModel.totalPercentage);
        totalGradePoints += gradePoints * course.credits;
        totalGradeCredits += course.credits;
      }
    }

    final gpa = totalGradeCredits > 0
        ? totalGradePoints / totalGradeCredits
        : 0.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'ACADEMIC TRANSCRIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'My Pi Student Assistant App',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated: ${DateTime.now().toString().substring(0, 19)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'Document: $filename',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Student Information
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'STUDENT INFORMATION',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Name: ${user?.displayName ?? user?.email?.split('@')[0] ?? 'Student'}',
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Email: ${user?.email ?? 'N/A'}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Report Type: ${_getReportTypeLabel(filename)}',
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text('Total Courses: ${courses.length}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Academic Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'ACADEMIC SUMMARY',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Total Credits: ${totalCredits.toStringAsFixed(1)}',
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Completed Courses: ${completedCourses.length}',
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Overall GPA: ${gpa.toStringAsFixed(2)}'),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Grade Credits: ${totalGradeCredits.toStringAsFixed(1)}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Course List Header
          pw.Text(
            'COURSE DETAILS',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),

          pw.SizedBox(height: 12),

          // Course Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Course Code',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Course Name',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Instructor',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Credits',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Grade',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Status',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Course Rows
              ...courses.map((course) {
                final gradeModel = courseGrades[course.id];
                final gradeText = gradeModel != null
                    ? '${gradeModel.totalPercentage.toStringAsFixed(1)}%'
                    : 'N/A';

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(course.code ?? 'N/A'),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(course.name),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(course.teacherName),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(course.credits.toString()),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(gradeText),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(course.status.toUpperCase()),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),

          pw.SizedBox(height: 20),

          // Footer
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NOTES',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '- This transcript is generated by My Pi Student Assistant App',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '- GPA is calculated based on completed courses with grades',
                  style: pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  '- This is an unofficial transcript for personal use only',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save and open PDF
    await _savePdf(pdf, filename);
  }

  String _getReportTypeLabel(String filename) {
    if (filename.contains('Full')) return 'Complete Academic Record';
    if (filename.contains('Completed')) return 'Completed Courses Only';
    if (filename.contains('Selected')) return 'Selected Courses Report';
    return 'Academic Report';
  }

  double _getGradePoints(double grade) {
    if (grade >= 90) return 4.0;
    if (grade >= 80) return 3.0;
    if (grade >= 70) return 2.0;
    if (grade >= 60) return 1.0;
    return 0.0;
  }

  Future<void> _savePdf(pw.Document pdf, String filename) async {
    try {
      // Use printing package to share/save the PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '$filename.pdf',
      );

      // Show success message
      Get.snackbar(
        'Success',
        'Transcript generated successfully! You can now save or share it.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      print('Error saving PDF: $e');
      Get.snackbar(
        'Error',
        'Failed to save transcript: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
