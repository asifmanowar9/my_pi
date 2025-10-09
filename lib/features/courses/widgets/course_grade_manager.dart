import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/course_grade_model.dart';
import '../../../core/database/database_helper_clean.dart';

class CourseGradeManager extends StatefulWidget {
  final String courseId;
  final CourseGradeModel? existingGrade;
  final Function(CourseGradeModel) onGradeUpdated;

  const CourseGradeManager({
    Key? key,
    required this.courseId,
    this.existingGrade,
    required this.onGradeUpdated,
  }) : super(key: key);

  @override
  State<CourseGradeManager> createState() => _CourseGradeManagerState();
}

class _CourseGradeManagerState extends State<CourseGradeManager> {
  late CourseGradeModel _currentGrade;
  final _dbHelper = DatabaseHelper();

  // Controllers for quizzes (support up to 4)
  final List<TextEditingController> _quizControllers = [];
  final List<TextEditingController> _quizMaxControllers = [];

  // Controllers for lab reports (support multiple)
  final List<TextEditingController> _labControllers = [];
  final List<TextEditingController> _labMaxControllers = [];

  // Controllers for assignments
  final List<TextEditingController> _assignmentControllers = [];
  final List<TextEditingController> _assignmentMaxControllers = [];

  // Controllers for single assessments
  final TextEditingController _midtermController = TextEditingController();
  final TextEditingController _midtermMaxController = TextEditingController();
  final TextEditingController _presentationController = TextEditingController();
  final TextEditingController _presentationMaxController =
      TextEditingController();
  final TextEditingController _finalController = TextEditingController();
  final TextEditingController _finalMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentGrade =
        widget.existingGrade ??
        CourseGradeModel(
          id: const Uuid().v4(),
          courseId: widget.courseId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize quiz controllers
    for (int i = 0; i < 4; i++) {
      final marks = i < _currentGrade.quizMarks.length
          ? _currentGrade.quizMarks[i]
          : null;
      final maxMarks = i < _currentGrade.quizMaxMarks.length
          ? _currentGrade.quizMaxMarks[i]
          : null;

      _quizControllers.add(
        TextEditingController(text: marks?.toString() ?? ''),
      );
      _quizMaxControllers.add(
        TextEditingController(text: maxMarks?.toString() ?? ''),
      );
    }

    // Initialize lab controllers (start with existing or 1 empty)
    if (_currentGrade.assignmentMarks.isEmpty) {
      _labControllers.add(TextEditingController());
      _labMaxControllers.add(TextEditingController());
    }

    // Initialize single assessment controllers
    _midtermController.text = _currentGrade.midtermMark?.toString() ?? '';
    _midtermMaxController.text = _currentGrade.midtermMaxMark?.toString() ?? '';
    _presentationController.text =
        _currentGrade.presentationMark?.toString() ?? '';
    _presentationMaxController.text =
        _currentGrade.presentationMaxMark?.toString() ?? '';
    _finalController.text = _currentGrade.finalExamMark?.toString() ?? '';
    _finalMaxController.text = _currentGrade.finalExamMaxMark?.toString() ?? '';
  }

  @override
  void dispose() {
    for (var controller in _quizControllers) {
      controller.dispose();
    }
    for (var controller in _quizMaxControllers) {
      controller.dispose();
    }
    for (var controller in _labControllers) {
      controller.dispose();
    }
    for (var controller in _labMaxControllers) {
      controller.dispose();
    }
    for (var controller in _assignmentControllers) {
      controller.dispose();
    }
    for (var controller in _assignmentMaxControllers) {
      controller.dispose();
    }
    _midtermController.dispose();
    _midtermMaxController.dispose();
    _presentationController.dispose();
    _presentationMaxController.dispose();
    _finalController.dispose();
    _finalMaxController.dispose();
    super.dispose();
  }

  Future<void> _saveGrade() async {
    try {
      // Collect quiz marks
      final quizMarks = <double>[];
      final quizMaxMarks = <double>[];
      for (int i = 0; i < _quizControllers.length; i++) {
        final marks = double.tryParse(_quizControllers[i].text);
        final maxMarks = double.tryParse(_quizMaxControllers[i].text);
        if (marks != null && maxMarks != null && maxMarks > 0) {
          quizMarks.add(marks);
          quizMaxMarks.add(maxMarks);
        }
      }

      // Collect assignment marks (using lab controllers)
      final assignmentMarks = <double>[];
      final assignmentMaxMarks = <double>[];
      for (int i = 0; i < _labControllers.length; i++) {
        final marks = double.tryParse(_labControllers[i].text);
        final maxMarks = double.tryParse(_labMaxControllers[i].text);
        if (marks != null && maxMarks != null && maxMarks > 0) {
          assignmentMarks.add(marks);
          assignmentMaxMarks.add(maxMarks);
        }
      }

      // Create updated grade model
      final updatedGrade = _currentGrade.copyWith(
        quizMarks: quizMarks,
        quizMaxMarks: quizMaxMarks,
        assignmentMarks: assignmentMarks,
        assignmentMaxMarks: assignmentMaxMarks,
        midtermMark: double.tryParse(_midtermController.text),
        midtermMaxMark: double.tryParse(_midtermMaxController.text),
        presentationMark: double.tryParse(_presentationController.text),
        presentationMaxMark: double.tryParse(_presentationMaxController.text),
        finalExamMark: double.tryParse(_finalController.text),
        finalExamMaxMark: double.tryParse(_finalMaxController.text),
        updatedAt: DateTime.now(),
      );

      // Save to database
      final gradeMap = updatedGrade.toJson();
      final existingGrade = await _dbHelper.getCourseGrade(widget.courseId);

      if (existingGrade != null) {
        await _dbHelper.updateCourseGrade(updatedGrade.id, gradeMap);
      } else {
        await _dbHelper.insertCourseGrade(gradeMap);
      }

      widget.onGradeUpdated(updatedGrade);
      Get.back();
      Get.snackbar(
        'Success',
        'Grade saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save grade: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Course Grades'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveGrade),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GPA Display Card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current GPA',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentGrade.gpa.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_currentGrade.letterGrade} • ${_currentGrade.totalPercentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quizzes Section
          _buildSectionHeader('Quizzes (10%)', Icons.quiz),
          const SizedBox(height: 8),
          ...List.generate(4, (index) => _buildQuizField(index + 1)),
          const SizedBox(height: 16),

          // Lab Reports Section
          _buildSectionHeader('Lab Reports (10%)', Icons.science),
          const SizedBox(height: 8),
          ...List.generate(
            _labControllers.length,
            (index) => _buildLabField(index + 1),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _labControllers.add(TextEditingController());
                _labMaxControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Lab Report'),
          ),
          const SizedBox(height: 16),

          // Midterm Section
          _buildSectionHeader('Midterm Exam (25%)', Icons.book),
          const SizedBox(height: 8),
          _buildSingleAssessmentField(
            'Midterm',
            _midtermController,
            _midtermMaxController,
          ),
          const SizedBox(height: 16),

          // Presentation Section
          _buildSectionHeader('Presentation (5%)', Icons.present_to_all),
          const SizedBox(height: 8),
          _buildSingleAssessmentField(
            'Presentation',
            _presentationController,
            _presentationMaxController,
          ),
          const SizedBox(height: 16),

          // Final Exam Section
          _buildSectionHeader('Final Exam (35%)', Icons.assignment),
          const SizedBox(height: 8),
          _buildSingleAssessmentField(
            'Final Exam',
            _finalController,
            _finalMaxController,
          ),
          const SizedBox(height: 16),

          // Assignments Section (15%)
          _buildSectionHeader('Assignments (15%)', Icons.assignment_turned_in),
          const Text(
            'Assignments are managed separately in the Assignments tab',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuizField(int quizNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Quiz $quizNumber:')),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _quizControllers[quizNumber - 1],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          const Text('out of'),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _quizMaxControllers[quizNumber - 1],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabField(int labNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Lab $labNumber:')),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _labControllers[labNumber - 1],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8),
          const Text('out of'),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _labMaxControllers[labNumber - 1],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleAssessmentField(
    String label,
    TextEditingController marksController,
    TextEditingController maxController,
  ) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text('$label:')),
        Expanded(
          flex: 3,
          child: TextField(
            controller: marksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Marks',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        const Text('out of'),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }
}
