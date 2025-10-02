import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grades', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            onPressed: () => Get.toNamed('/transcript'),
            tooltip: 'View Transcript',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_GradeSummary(), SizedBox(height: 24), _CourseGrades()],
        ),
      ),
    );
  }
}

class _GradeSummary extends StatelessWidget {
  const _GradeSummary();

  @override
  Widget build(BuildContext context) {
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
                    title: 'Current GPA',
                    value: '3.78',
                    subtitle: 'Fall 2025',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GPACard(
                    title: 'Cumulative GPA',
                    value: '3.65',
                    subtitle: 'Overall',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(label: 'Credits Completed', value: '45'),
                ),
                Expanded(
                  child: _InfoItem(label: 'Credits in Progress', value: '15'),
                ),
                Expanded(
                  child: _InfoItem(label: 'Total Credits', value: '120'),
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
            style: AppTextStyles.cardTitle?.copyWith(
              color: color,
              fontSize: 28,
            ),
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
        Text(value, style: AppTextStyles.cardTitle?.copyWith(fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
      ],
    );
  }
}

class _CourseGrades extends StatelessWidget {
  const _CourseGrades();

  @override
  Widget build(BuildContext context) {
    final grades = [
      GradeData(
        courseId: 'cs101',
        courseName: 'Introduction to Computer Science',
        courseCode: 'CS 101',
        currentGrade: 'A',
        percentage: 94.5,
        credits: 3,
        assignments: [
          AssignmentGrade('Assignment 1', 95, 20),
          AssignmentGrade('Assignment 2', 92, 20),
          AssignmentGrade('Midterm Exam', 96, 30),
          AssignmentGrade('Final Project', 93, 30),
        ],
      ),
      GradeData(
        courseId: 'math201',
        courseName: 'Calculus II',
        courseCode: 'MATH 201',
        currentGrade: 'B+',
        percentage: 87.2,
        credits: 4,
        assignments: [
          AssignmentGrade('Problem Set 1', 85, 15),
          AssignmentGrade('Problem Set 2', 88, 15),
          AssignmentGrade('Midterm Exam', 82, 35),
          AssignmentGrade('Final Exam', 90, 35),
        ],
      ),
      GradeData(
        courseId: 'phys301',
        courseName: 'Physics III',
        courseCode: 'PHYS 301',
        currentGrade: 'A-',
        percentage: 91.8,
        credits: 3,
        assignments: [
          AssignmentGrade('Lab Report 1', 94, 25),
          AssignmentGrade('Lab Report 2', 89, 25),
          AssignmentGrade('Theory Exam', 92, 50),
        ],
      ),
      GradeData(
        courseId: 'eng101',
        courseName: 'English Composition',
        courseCode: 'ENG 101',
        currentGrade: 'B',
        percentage: 83.5,
        credits: 3,
        assignments: [
          AssignmentGrade('Essay 1', 80, 25),
          AssignmentGrade('Essay 2', 85, 25),
          AssignmentGrade('Research Paper', 86, 35),
          AssignmentGrade('Participation', 82, 15),
        ],
      ),
      GradeData(
        courseId: 'chem201',
        courseName: 'Organic Chemistry',
        courseCode: 'CHEM 201',
        currentGrade: 'B+',
        percentage: 88.7,
        credits: 4,
        assignments: [
          AssignmentGrade('Quiz 1', 92, 10),
          AssignmentGrade('Quiz 2', 85, 10),
          AssignmentGrade('Lab Reports', 90, 30),
          AssignmentGrade('Midterm', 87, 25),
          AssignmentGrade('Final', 89, 25),
        ],
      ),
    ];

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
              Text('Assignment Breakdown', style: AppTextStyles.cardSubtitle),
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
                        '${assignment.score}% ',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '(${assignment.weight}%)',
                        style: AppTextStyles.caption.copyWith(
                          color: Get.theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Get.toNamed('/grade/${grade.courseId}');
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
  final double weight;

  AssignmentGrade(this.name, this.score, this.weight);
}
