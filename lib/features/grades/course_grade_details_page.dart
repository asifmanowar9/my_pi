import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/themes/app_text_styles.dart';
import '../../shared/themes/app_colors.dart';
import '../courses/controllers/course_controller.dart';
import '../courses/controllers/assessment_controller.dart';
import '../courses/services/grade_calculation_service.dart';
import '../courses/models/assessment_model.dart';
import '../courses/models/course_model.dart';

class CourseGradeDetailsPage extends StatelessWidget {
  final String courseId;

  const CourseGradeDetailsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final assessmentController = Get.find<AssessmentController>();

    // Get course
    final course = courseController.courses.firstWhereOrNull(
      (c) => c.id == courseId,
    );

    if (course == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Course Not Found')),
        body: const Center(child: Text('Course not found')),
      );
    }

    // Get assessments
    final assessments = assessmentController.assessments
        .where((a) => a.courseId == courseId)
        .toList();

    if (assessments.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(course.name)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assessment_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No assessments yet'),
              SizedBox(height: 8),
              Text('Add assessments to see grade analytics'),
            ],
          ),
        ),
      );
    }

    // Calculate grade
    final gradeData = GradeCalculationService.calculateCourseGrade(assessments);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.name, style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              courseController.loadCourses();
              assessmentController.loadAllAssessments();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Grade Summary
            _OverallGradeSummary(course: course, gradeData: gradeData),
            const SizedBox(height: 24),

            // Grade Distribution Pie Chart
            _GradeDistributionChart(
              assessments: assessments,
              gradeData: gradeData,
            ),
            const SizedBox(height: 24),

            // Progress Bars by Assessment Type
            _AssessmentTypeProgress(assessments: assessments),
            const SizedBox(height: 24),

            // Timeline Chart
            _GradeTimelineChart(assessments: assessments),
            const SizedBox(height: 24),

            // Statistics Grid
            _StatisticsGrid(assessments: assessments, gradeData: gradeData),
            const SizedBox(height: 24),

            // Assessment Breakdown List
            _AssessmentBreakdown(assessments: assessments),
          ],
        ),
      ),
    );
  }
}

class _OverallGradeSummary extends StatelessWidget {
  final CourseModel course;
  final Map<String, dynamic> gradeData;

  const _OverallGradeSummary({required this.course, required this.gradeData});

  @override
  Widget build(BuildContext context) {
    final percentage = gradeData['percentage'] as double;
    final letterGrade = gradeData['letterGrade'] as String;
    final gpa = gradeData['gpa'] as double;
    final status = gradeData['status'] as String;
    final isPassing = gradeData['isPassing'] as bool;

    final gradeColor = AppColors.getGradeColor(letterGrade);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Overall Grade', style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      Text(
                        letterGrade,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontSize: 48,
                          color: gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        status,
                        style: AppTextStyles.caption.copyWith(
                          color: gradeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: gradeColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: gradeColor,
                        ),
                      ),
                      Text(
                        'GPA: ${gpa.toStringAsFixed(2)}',
                        style: AppTextStyles.caption.copyWith(
                          color: gradeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPassing ? '✓ Passing' : '✗ Not Passing',
                  style: AppTextStyles.caption.copyWith(
                    color: isPassing ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${gradeData['totalMarks']}/${gradeData['totalMaxMarks']} marks',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeDistributionChart extends StatelessWidget {
  final List<AssessmentModel> assessments;
  final Map<String, dynamic> gradeData;

  const _GradeDistributionChart({
    required this.assessments,
    required this.gradeData,
  });

  @override
  Widget build(BuildContext context) {
    final byType = gradeData['byType'] as Map<AssessmentType, double>;
    final maxByType = gradeData['maxByType'] as Map<AssessmentType, double>;

    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int colorIndex = 0;
    byType.forEach((type, marks) {
      final maxMarks = maxByType[type] ?? 0;
      if (maxMarks > 0) {
        final percentage = (marks / maxMarks) * 100;
        sections.add(
          PieChartSectionData(
            value: marks,
            title: '${percentage.toStringAsFixed(0)}%',
            color: colors[colorIndex % colors.length],
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIndex++;
      }
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grade Distribution', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            // Pie Chart centered
            Center(
              child: SizedBox(
                height: 200,
                width: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Legend below the chart
            Column(
              children: () {
                int legendColorIndex = 0;
                return byType.entries.map((entry) {
                  final type = entry.key;
                  final color = colors[legendColorIndex % colors.length];
                  legendColorIndex++;
                  final maxMarks = maxByType[type] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${type.displayName}: ${entry.value.toStringAsFixed(1)}/${maxMarks.toStringAsFixed(0)}',
                            style: AppTextStyles.caption.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              }(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTypeProgress extends StatelessWidget {
  final List<AssessmentModel> assessments;

  const _AssessmentTypeProgress({required this.assessments});

  @override
  Widget build(BuildContext context) {
    // Group by type
    final byType = <AssessmentType, List<AssessmentModel>>{};
    for (var assessment in assessments.where((a) => a.isGraded)) {
      byType.putIfAbsent(assessment.type, () => []).add(assessment);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress by Assessment Type', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            ...byType.entries.map((entry) {
              final type = entry.key;
              final typeAssessments = entry.value;

              // Calculate average for this type
              double totalMarks = 0;
              double totalMaxMarks = 0;
              for (var a in typeAssessments) {
                totalMarks += a.marks ?? 0;
                totalMaxMarks += a.maxMarks ?? 0;
              }

              final percentage = totalMaxMarks > 0
                  ? (totalMarks / totalMaxMarks) * 100
                  : 0.0;

              final color = percentage >= 80
                  ? Colors.green
                  : percentage >= 70
                  ? Colors.blue
                  : percentage >= 60
                  ? Colors.orange
                  : Colors.red;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              type.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type.displayName,
                              style: AppTextStyles.cardSubtitle,
                            ),
                          ],
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${typeAssessments.length} assessment${typeAssessments.length > 1 ? 's' : ''} • ${totalMarks.toStringAsFixed(1)}/${totalMaxMarks.toStringAsFixed(0)} marks',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _GradeTimelineChart extends StatelessWidget {
  final List<AssessmentModel> assessments;

  const _GradeTimelineChart({required this.assessments});

  @override
  Widget build(BuildContext context) {
    final gradedAssessments = assessments.where((a) => a.isGraded).toList()
      ..sort(
        (a, b) =>
            (a.dueDate ?? a.createdAt).compareTo(b.dueDate ?? b.createdAt),
      );

    if (gradedAssessments.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < gradedAssessments.length; i++) {
      final assessment = gradedAssessments[i];
      final percentage = assessment.percentage ?? 0;
      spots.add(FlSpot(i.toDouble(), percentage));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grade Timeline', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 20,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[300], strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 20,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: AppTextStyles.caption,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 70,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < gradedAssessments.length) {
                            final assessment = gradedAssessments[index];
                            // Abbreviate title if too long
                            String displayTitle = assessment.title;
                            if (displayTitle.length > 10) {
                              displayTitle =
                                  '${displayTitle.substring(0, 8)}..';
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: -0.5,
                                child: Text(
                                  displayTitle,
                                  style: const TextStyle(fontSize: 11),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: (gradedAssessments.length - 1).toDouble(),
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < gradedAssessments.length) {
                            final assessment = gradedAssessments[index];
                            return LineTooltipItem(
                              '${assessment.type.displayName} #${index + 1}\n${assessment.title}\n${assessment.marks}/${assessment.maxMarks} (${spot.y.toStringAsFixed(1)}%)',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticsGrid extends StatelessWidget {
  final List<AssessmentModel> assessments;
  final Map<String, dynamic> gradeData;

  const _StatisticsGrid({required this.assessments, required this.gradeData});

  @override
  Widget build(BuildContext context) {
    final gradedAssessments = assessments.where((a) => a.isGraded).toList();
    final completedCount = assessments.where((a) => a.isCompleted).length;
    final avgPercentage = gradedAssessments.isNotEmpty
        ? gradedAssessments
                  .map((a) => a.percentage ?? 0)
                  .reduce((a, b) => a + b) /
              gradedAssessments.length
        : 0.0;

    final highest = gradedAssessments.isNotEmpty
        ? gradedAssessments
              .map((a) => a.percentage ?? 0)
              .reduce((a, b) => a > b ? a : b)
        : 0.0;

    final lowest = gradedAssessments.isNotEmpty
        ? gradedAssessments
              .map((a) => a.percentage ?? 0)
              .reduce((a, b) => a < b ? a : b)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _StatCard(
                  icon: Icons.assignment_turned_in,
                  label: 'Completed',
                  value: '$completedCount/${assessments.length}',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.grading,
                  label: 'Graded',
                  value: '${gradedAssessments.length}/${assessments.length}',
                  color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.trending_up,
                  label: 'Average',
                  value: '${avgPercentage.toStringAsFixed(1)}%',
                  color: Colors.purple,
                ),
                _StatCard(
                  icon: Icons.star,
                  label: 'Highest',
                  value: '${highest.toStringAsFixed(1)}%',
                  color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.arrow_downward,
                  label: 'Lowest',
                  value: gradedAssessments.isNotEmpty
                      ? '${lowest.toStringAsFixed(1)}%'
                      : 'N/A',
                  color: Colors.red,
                ),
                _StatCard(
                  icon: Icons.pending_actions,
                  label: 'Pending',
                  value: '${assessments.length - completedCount}',
                  color: Colors.amber,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(color: color, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssessmentBreakdown extends StatelessWidget {
  final List<AssessmentModel> assessments;

  const _AssessmentBreakdown({required this.assessments});

  @override
  Widget build(BuildContext context) {
    final sortedAssessments = assessments.toList()
      ..sort((a, b) {
        // Sort by graded first, then by percentage descending
        if (a.isGraded && !b.isGraded) return -1;
        if (!a.isGraded && b.isGraded) return 1;
        if (a.isGraded && b.isGraded) {
          return (b.percentage ?? 0).compareTo(a.percentage ?? 0);
        }
        return 0;
      });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assessment Breakdown', style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            ...sortedAssessments.map((assessment) {
              final percentage = assessment.percentage ?? 0;
              final color = assessment.isGraded
                  ? (percentage >= 80
                        ? Colors.green
                        : percentage >= 70
                        ? Colors.blue
                        : percentage >= 60
                        ? Colors.orange
                        : Colors.red)
                  : Colors.grey;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          assessment.type.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assessment.title,
                            style: AppTextStyles.cardSubtitle,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  assessment.type.displayName,
                                  style: AppTextStyles.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (assessment.isGraded) ...[
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '${assessment.marks}/${assessment.maxMarks} marks',
                                    style: AppTextStyles.caption.copyWith(
                                      color: color,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (assessment.isGraded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          assessment.isCompleted ? 'Pending' : 'Not Done',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
