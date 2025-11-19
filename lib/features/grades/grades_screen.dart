import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';
import '../courses/controllers/course_controller.dart';
import '../courses/controllers/assessment_controller.dart';
import '../courses/services/grade_calculation_service.dart';
import '../courses/models/assessment_model.dart';
import 'course_grade_details_page.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    final courseController = Get.put(CourseController());
    final assessmentController = Get.put(AssessmentController());

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      courseController.loadCourses();
      assessmentController.loadAllAssessments();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Grades', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              courseController.loadCourses();
              assessmentController.loadAllAssessments();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (courseController.isLoading ||
            assessmentController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradeSummary(
                courseController: courseController,
                assessmentController: assessmentController,
              ),
              const SizedBox(height: 24),
              _CourseGrades(
                courseController: courseController,
                assessmentController: assessmentController,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _GradeSummary extends StatelessWidget {
  final CourseController courseController;
  final AssessmentController assessmentController;

  const _GradeSummary({
    required this.courseController,
    required this.assessmentController,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate overall GPA from all courses
    double totalGPA = 0;
    int coursesWithGrades = 0;

    for (var course in courseController.courses) {
      final courseAssessments = assessmentController.assessments
          .where((a) => a.courseId == course.id)
          .toList();

      if (courseAssessments.any((a) => a.isGraded)) {
        final gradeData = GradeCalculationService.calculateCourseGrade(
          courseAssessments,
        );
        totalGPA += gradeData['gpa'] as double;
        coursesWithGrades++;
      }
    }

    final averageGPA = coursesWithGrades > 0
        ? totalGPA / coursesWithGrades
        : 0.0;
    final totalCourses = courseController.courses.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Academic Progress', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GPACard(
                    title: 'Overall GPA',
                    value: averageGPA.toStringAsFixed(2),
                    subtitle: '$coursesWithGrades graded courses',
                    color: averageGPA >= 3.5
                        ? Colors.green
                        : averageGPA >= 3.0
                        ? Colors.blue
                        : averageGPA >= 2.0
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GPACard(
                    title: 'Total Courses',
                    value: totalCourses.toString(),
                    subtitle: '$coursesWithGrades with grades',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Total Assessments',
                    value: assessmentController.assessments.length.toString(),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Completed',
                    value: assessmentController.assessments
                        .where((a) => a.isCompleted)
                        .length
                        .toString(),
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    label: 'Graded',
                    value: assessmentController.assessments
                        .where((a) => a.isGraded)
                        .length
                        .toString(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GPACard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _GPACard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CourseGrades extends StatelessWidget {
  final CourseController courseController;
  final AssessmentController assessmentController;

  const _CourseGrades({
    required this.courseController,
    required this.assessmentController,
  });

  @override
  Widget build(BuildContext context) {
    // Build grade data from real courses and assessments
    final grades = courseController.courses
        .map((course) {
          final courseAssessments = assessmentController.assessments
              .where((a) => a.courseId == course.id)
              .toList();

          if (courseAssessments.isEmpty) {
            return null; // Skip courses without assessments
          }

          // Calculate grade
          final gradeData = GradeCalculationService.calculateCourseGrade(
            courseAssessments,
          );

          final percentage = gradeData['percentage'] as double;
          final letterGrade = gradeData['letterGrade'] as String;

          // Get graded assessments for breakdown
          final gradedAssessments = courseAssessments
              .where((a) => a.isGraded)
              .map(
                (a) => AssignmentGrade(
                  '${a.type.icon} ${a.title}',
                  a.marks ?? 0,
                  a.maxMarks ?? 0,
                  a.type.weight,
                ),
              )
              .toList();

          return GradeData(
            courseId: course.id,
            courseName: course.name,
            courseCode: course.name, // Using name as code for now
            currentGrade: letterGrade,
            percentage: percentage,
            credits: 3, // Default credit hours, could be made configurable
            assignments: gradedAssessments,
          );
        })
        .whereType<GradeData>()
        .toList(); // Filter out null values

    if (grades.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.grade_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No grades yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add assessments and grades to see them here',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Course Grades', style: AppTextStyles.cardTitle),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: grades.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GradeCard(grade: grades[index]),
            );
          },
        ),
      ],
    );
  }
}

class _GradeCard extends StatelessWidget {
  final GradeData grade;

  const _GradeCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    final gradeColor = AppColors.getGradeColor(grade.currentGrade);

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              grade.courseCode,
              style: AppTextStyles.courseCode.copyWith(color: gradeColor),
            ),
            Text(grade.courseName, style: AppTextStyles.cardSubtitle),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Text(
                '${grade.percentage.toStringAsFixed(1)}%',
                style: AppTextStyles.caption,
              ),
              const SizedBox(width: 8),
              Text('${grade.credits} credits', style: AppTextStyles.caption),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: gradeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            grade.currentGrade,
            style: AppTextStyles.gradeText.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          const Divider(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assessment Breakdown', style: AppTextStyles.cardSubtitle),
              const SizedBox(height: 12),
              ...grade.assignments.map(
                (assignment) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          assignment.name,
                          style: AppTextStyles.caption,
                        ),
                      ),
                      Text(
                        '${assignment.score.toStringAsFixed(assignment.score.truncateToDouble() == assignment.score ? 0 : 1)} / ${assignment.maxScore.toStringAsFixed(assignment.maxScore.truncateToDouble() == assignment.maxScore ? 0 : 1)} ',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Text(
                      //   '(${assignment.weight}%)',
                      //   style: AppTextStyles.caption.copyWith(
                      //     color: Get.theme.colorScheme.onSurfaceVariant
                      //         .withOpacity(0.7),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.to(
                      () => CourseGradeDetailsPage(courseId: grade.courseId),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GradeData {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String currentGrade;
  final double percentage;
  final int credits;
  final List<AssignmentGrade> assignments;

  GradeData({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.currentGrade,
    required this.percentage,
    required this.credits,
    required this.assignments,
  });
}

class AssignmentGrade {
  final String name;
  final double score;
  final double maxScore;
  final double weight;

  AssignmentGrade(this.name, this.score, this.maxScore, this.weight);
}
