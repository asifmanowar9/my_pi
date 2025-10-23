import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';
import '../models/class_schedule_entry.dart';
import '../services/course_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../shared/services/storage_service.dart';
import '../../../shared/services/notification_service.dart';

class CourseController extends GetxController {
  static CourseController get instance => Get.find();

  final CourseService _courseService = Get.find<CourseService>();

  // Safe AuthController getter
  AuthController? get _safeAuthController {
    try {
      return Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;
    } catch (e) {
      return null;
    }
  }

  // Observable lists - Requirement 1: Reactive course list with RxList<Course>
  final RxList<CourseModel> _courses = <CourseModel>[].obs;
  final RxList<CourseModel> _filteredCourses = <CourseModel>[].obs;

  // Loading states - Requirement 4: Loading states for UI feedback
  final RxBool _isLoading = false.obs;
  final RxBool _isCreating = false.obs;
  final RxBool _isUpdating = false.obs;
  final RxBool _isDeleting = false.obs;
  final RxBool _isSyncing = false.obs;
  final RxBool _isSearching = false.obs;

  // Search and filter - Requirement 3: Search and filtering with reactive updates
  final RxString _searchQuery = ''.obs;
  final RxString _selectedTeacher = ''.obs;
  final RxString _selectedClassroom = ''.obs;
  final RxString _selectedSemester = ''.obs;
  final RxInt _minCredits = 0.obs;
  final RxInt _maxCredits = 20.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController teacherController = TextEditingController();
  final TextEditingController classroomController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController creditsController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  // Date selection for course duration
  final Rx<DateTime?> _startDate = Rx<DateTime?>(null);
  DateTime? get startDate => _startDate.value;
  void setStartDate(DateTime? date) => _startDate.value = date;

  // Schedule notification fields - Multiple day-time combinations
  final RxList<ClassScheduleEntry> _scheduleEntries = <ClassScheduleEntry>[].obs;
  final RxInt _reminderMinutes = 0.obs;

  List<ClassScheduleEntry> get scheduleEntries => _scheduleEntries;
  int get reminderMinutes => _reminderMinutes.value;

  // Backward compatibility getters
  List<int> get selectedDays => _scheduleEntries.map((e) => e.dayOfWeek).toList();
  TimeOfDay? get classTime => _scheduleEntries.isNotEmpty ? _scheduleEntries.first.time : null;

  // Add a new schedule entry (day + time combination)
  void addScheduleEntry(int dayOfWeek, TimeOfDay time) {
    final entry = ClassScheduleEntry(dayOfWeek: dayOfWeek, time: time);
    // Remove existing entry for the same day if it exists
    _scheduleEntries.removeWhere((e) => e.dayOfWeek == dayOfWeek);
    // Add the new entry
    _scheduleEntries.add(entry);
    _scheduleEntries.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    _updateScheduleController();
  }

  // Remove a schedule entry for a specific day
  void removeScheduleEntry(int dayOfWeek) {
    _scheduleEntries.removeWhere((e) => e.dayOfWeek == dayOfWeek);
    _updateScheduleController();
  }

  // Update time for an existing day
  void updateScheduleEntryTime(int dayOfWeek, TimeOfDay time) {
    final index = _scheduleEntries.indexWhere((e) => e.dayOfWeek == dayOfWeek);
    if (index != -1) {
      _scheduleEntries[index] = ClassScheduleEntry(dayOfWeek: dayOfWeek, time: time);
      _updateScheduleController();
    }
  }

  // Check if a day has a schedule entry
  bool hasScheduleForDay(int dayOfWeek) {
    return _scheduleEntries.any((e) => e.dayOfWeek == dayOfWeek);
  }

  // Get time for a specific day
  TimeOfDay? getTimeForDay(int dayOfWeek) {
    final entry = _scheduleEntries.firstWhereOrNull((e) => e.dayOfWeek == dayOfWeek);
    return entry?.time;
  }

  // Backward compatibility methods
  void toggleWeekday(int day) {
    if (hasScheduleForDay(day)) {
      removeScheduleEntry(day);
    } else {
      // Add with default time (9:00 AM)
      addScheduleEntry(day, const TimeOfDay(hour: 9, minute: 0));
    }
  }

  void setClassTime(TimeOfDay? time) {
    if (time != null && _scheduleEntries.isNotEmpty) {
      // Update time for the first entry (backward compatibility)
      updateScheduleEntryTime(_scheduleEntries.first.dayOfWeek, time);
    }
  }

  void setReminderMinutes(int minutes) => _reminderMinutes.value = minutes;

  // Generate formatted schedule string from structured data
  String _generateScheduleString() {
    if (_scheduleEntries.isEmpty) {
      return '';
    }

    // Sort entries by day
    final sortedEntries = List<ClassScheduleEntry>.from(_scheduleEntries)
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    // Format each entry as "Day Time"
    final scheduleStrings = sortedEntries.map((entry) => entry.toString()).toList();

    // Join with semicolons for multiple entries
    return scheduleStrings.join('; ');
  }

  // Update schedule controller with formatted string (for backward compatibility)
  void _updateScheduleController() {
    scheduleController.text = _generateScheduleString();
  }

  // Color selection
  final Rx<Color?> _selectedColor = Rx<Color?>(null);

  // Form validation
  final GlobalKey<FormState> courseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(); // Alias for UI compatibility

  // Selected course for editing
  final Rx<CourseModel?> _selectedCourse = Rx<CourseModel?>(null);

  // Error message for form validation
  final RxString _errorMessage = ''.obs;

  // Daily sync tracking - Cloud sync once per day
  final RxString _lastSyncDate = ''.obs;
  final RxBool _autoSyncEnabled = true.obs;

  // Statistics - Requirement 8: Statistics calculation for dashboard widgets
  final RxMap<String, int> _statistics = <String, int>{}.obs;
  final RxMap<String, double> _advancedStats = <String, double>{}.obs;
  final RxList<String> _teachers = <String>[].obs;
  final RxList<String> _classrooms = <String>[].obs;
  final RxList<String> _semesters = <String>[].obs;

  // Getters
  List<CourseModel> get courses => _courses;
  List<CourseModel> get filteredCourses => _filteredCourses;
  bool get isLoading => _isLoading.value;
  bool get isCreating => _isCreating.value;
  bool get isUpdating => _isUpdating.value;
  bool get isDeleting => _isDeleting.value;
  bool get isSyncing => _isSyncing.value;
  bool get isSearching => _isSearching.value;
  String get searchQuery => _searchQuery.value;
  String get selectedTeacher => _selectedTeacher.value;
  String get selectedClassroom => _selectedClassroom.value;
  String get selectedSemester => _selectedSemester.value;
  int get minCredits => _minCredits.value;
  int get maxCredits => _maxCredits.value;
  CourseModel? get selectedCourse => _selectedCourse.value;
  String get lastSyncDate => _lastSyncDate.value;
  bool get autoSyncEnabled => _autoSyncEnabled.value;
  Map<String, int> get statistics => _statistics;
  Map<String, double> get advancedStats => _advancedStats;
  List<String> get teachers => _teachers;
  List<String> get classrooms => _classrooms;
  List<String> get semesters => _semesters;
  String get errorMessage => _errorMessage.value;
  Color? get selectedColor => _selectedColor.value;

  @override
  void onInit() {
    super.onInit();
    loadLastSyncDate();
    loadCourses();
    loadStatistics();
    // Perform daily sync check after loading courses
    checkAndPerformDailySync();
  }

  @override
  void onClose() {
    nameController.dispose();
    teacherController.dispose();
    classroomController.dispose();
    scheduleController.dispose();
    descriptionController.dispose();
    creditsController.dispose();
    super.onClose();
  }

  // Core CRUD operations - Requirement 2: CRUD operations (add, update, delete, getAll)

  Future<void> loadCourses() async {
    try {
      _isLoading.value = true;
      final courseList = await _courseService.getAllCourses();

      // Update course statuses based on end dates
      await _updateCourseStatuses(courseList);

      _courses.value = courseList;
      _applyFilters();
      _updateUniqueValues();
    } catch (e) {
      _showErrorSnackbar('Failed to load courses', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // Automatically update course statuses based on end dates
  Future<void> _updateCourseStatuses(List<CourseModel> courses) async {
    final now = DateTime.now();
    bool needsUpdate = false;

    for (var course in courses) {
      if (course.endDate == null) continue;

      String newStatus;
      if (course.startDate != null && now.isBefore(course.startDate!)) {
        newStatus = 'upcoming';
      } else if (now.isAfter(course.endDate!)) {
        newStatus = 'completed';
      } else {
        newStatus = 'active';
      }

      // Only update if status has changed
      if (course.status != newStatus) {
        needsUpdate = true;
        final updatedCourse = course.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        try {
          await _courseService.updateCourse(updatedCourse);
        } catch (e) {
          print('Error updating course status: $e');
        }
      }
    }

    // Reload courses if any status was updated
    if (needsUpdate) {
      final updatedList = await _courseService.getAllCourses();
      courses.clear();
      courses.addAll(updatedList);
    }
  }

  Future<bool> createCourse() async {
    if (!_validateForm()) return false;

    try {
      _isCreating.value = true;
      _errorMessage.value = '';

      final course = _buildCourseFromForm();

      // Requirement 5: Form validation for course creation/editing
      final validationErrors = await _validateCourseData(course);
      if (validationErrors.isNotEmpty) {
        _errorMessage.value = validationErrors.first;
        return false;
      }

      await _courseService.createCourse(course);

      // Schedule notifications if schedule is set
      await _scheduleNotificationsForCourse(course);

      _showSuccessSnackbar('Course created successfully');
      clearForm();
      await loadCourses();
      await loadStatistics();

      if (Get.isDialogOpen == false && Get.isBottomSheetOpen == false) {
        Get.back();
      }
      return true;
    } catch (e) {
      _errorMessage.value = 'Failed to create course: ${e.toString()}';
      _showErrorSnackbar('Create Failed', e.toString());
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  Future<bool> updateCourse() async {
    if (!_validateForm() || _selectedCourse.value == null) return false;

    try {
      _isUpdating.value = true;

      final updatedCourse = _buildCourseFromForm(
        baseId: _selectedCourse.value!.id,
      );

      // Requirement 5: Form validation for course creation/editing
      final validationErrors = await _validateCourseData(
        updatedCourse,
        isUpdate: true,
      );
      if (validationErrors.isNotEmpty) {
        _showErrorSnackbar('Validation Error', validationErrors.first);
        return false;
      }

      await _courseService.updateCourse(updatedCourse);

      // Update notifications (cancel old, schedule new)
      await _scheduleNotificationsForCourse(updatedCourse);

      _showSuccessSnackbar('Course updated successfully');
      clearForm();
      await loadCourses();
      await loadStatistics();
      Get.back();
      return true;
    } catch (e) {
      _showErrorSnackbar('Update Failed', e.toString());
      return false;
    } finally {
      _isUpdating.value = false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    try {
      _isDeleting.value = true;

      final confirmed = await _showDeleteConfirmation();
      if (!confirmed) return false;

      await _courseService.deleteCourse(courseId);

      // Cancel notifications for this course
      await _cancelNotificationsForCourse(courseId);

      _showSuccessSnackbar('Course deleted successfully');
      await loadCourses();
      await loadStatistics();
      return true;
    } catch (e) {
      _showErrorSnackbar('Delete Failed', e.toString());
      return false;
    } finally {
      _isDeleting.value = false;
    }
  }

  // Duplicate course method for CourseCard widget
  Future<bool> duplicateCourse(CourseModel course) async {
    try {
      _isCreating.value = true;

      // Create a copy of the course with a new name
      final duplicatedCourse = CourseModel(
        id: '',
        userId: course.userId,
        name: '${course.name} (Copy)',
        code: course.code != null
            ? '${course.code}_COPY_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'
            : null,
        description: course.description,
        teacherName: course.teacherName,
        classroom: course.classroom,
        schedule: course.schedule,
        credits: course.credits,
        color: course.color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _courseService.createCourse(duplicatedCourse);

      _showSuccessSnackbar('Course duplicated successfully');
      await loadCourses();
      await loadStatistics();
      return true;
    } catch (e) {
      _showErrorSnackbar('Duplicate Failed', e.toString());
      return false;
    } finally {
      _isCreating.value = false;
    }
  }

  // Search and filter methods - Requirement 3: Search and filtering with reactive updates

  Future<void> setSearchQuery(String query) async {
    _isSearching.value = true;
    _searchQuery.value = query;
    await _applyFilters();
    _isSearching.value = false;
  }

  void setTeacherFilter(String teacher) {
    _selectedTeacher.value = teacher;
    _applyFilters();
  }

  void setClassroomFilter(String classroom) {
    _selectedClassroom.value = classroom;
    _applyFilters();
  }

  void setSemesterFilter(String semester) {
    _selectedSemester.value = semester;
    _applyFilters();
  }

  void setCreditFilter(int minCredits, int maxCredits) {
    _minCredits.value = minCredits;
    _maxCredits.value = maxCredits;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery.value = '';
    _selectedTeacher.value = '';
    _selectedClassroom.value = '';
    _selectedSemester.value = '';
    _minCredits.value = 0;
    _maxCredits.value = 20;
    _applyFilters();
  }

  Future<void> _applyFilters() async {
    List<CourseModel> filtered = List.from(_courses);

    // Apply search query
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      filtered = filtered.where((course) {
        return course.name.toLowerCase().contains(query) ||
            course.teacherName.toLowerCase().contains(query) ||
            course.classroom.toLowerCase().contains(query) ||
            course.schedule.toLowerCase().contains(query) ||
            (course.code?.toLowerCase().contains(query) ?? false) ||
            (course.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply teacher filter
    if (_selectedTeacher.value.isNotEmpty) {
      filtered = filtered
          .where((course) => course.teacherName == _selectedTeacher.value)
          .toList();
    }

    // Apply classroom filter
    if (_selectedClassroom.value.isNotEmpty) {
      filtered = filtered
          .where((course) => course.classroom == _selectedClassroom.value)
          .toList();
    }

    // Apply semester filter
    if (_selectedSemester.value.isNotEmpty) {
      filtered = filtered
          .where((course) => course.schedule.contains(_selectedSemester.value))
          .toList();
    }

    // Apply credit range filter
    if (_minCredits.value > 0 || _maxCredits.value < 20) {
      filtered = filtered.where((course) {
        return course.credits >= _minCredits.value &&
            course.credits <= _maxCredits.value;
      }).toList();
    }

    _filteredCourses.value = filtered;
  }

  // Form management

  void selectCourseForEditing(CourseModel course) {
    _selectedCourse.value = course;
    nameController.text = course.name;
    codeController.text = course.code ?? '';
    teacherController.text = course.teacherName;
    classroomController.text = course.classroom;
    scheduleController.text = course.schedule;
    descriptionController.text = course.description ?? '';
    creditsController.text = course.credits.toString();
    durationController.text = course.durationMonths?.toString() ?? '';
    _startDate.value = course.startDate;

    // Set schedule notification fields from course data
    _scheduleEntries.clear();
    if (course.scheduleDays != null && course.classTime != null && course.classTime!.isNotEmpty) {
      try {
        final parts = course.classTime!.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final time = TimeOfDay(hour: hour, minute: minute);
        
        // For backward compatibility, apply the same time to all days
        for (final day in course.scheduleDays!) {
          _scheduleEntries.add(ClassScheduleEntry(dayOfWeek: day, time: time));
        }
      } catch (e) {
        print('Error parsing course schedule: $e');
      }
    }
    _reminderMinutes.value = course.reminderMinutes ?? 0;

    // Set the color if available
    if (course.color != null && course.color!.isNotEmpty) {
      try {
        String colorString = course.color!;
        if (colorString.startsWith('#')) {
          colorString = colorString.substring(1);
        }
        if (colorString.length == 6) {
          colorString = 'FF$colorString'; // Add alpha channel
        }
        final colorValue = int.parse(colorString, radix: 16);
        _selectedColor.value = Color(colorValue);
      } catch (e) {
        _selectedColor.value = null;
      }
    } else {
      _selectedColor.value = null;
    }
  }

  void clearForm() {
    _selectedCourse.value = null;
    nameController.clear();
    codeController.clear();
    teacherController.clear();
    classroomController.clear();
    scheduleController.clear();
    descriptionController.clear();
    creditsController.text = '3';
    durationController.clear();
    _startDate.value = null;
    _selectedColor.value = null;
    _scheduleEntries.clear();
    _reminderMinutes.value = 0;
    formKey.currentState?.reset();
  }

  void setSelectedColor(Color? color) {
    _selectedColor.value = color;
  }

  // Material 3 compliant color palette for courses
  List<Color> get materialYouColors {
    final theme = Get.theme;
    return [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.colorScheme.primaryContainer,
      theme.colorScheme.secondaryContainer,
      theme.colorScheme.tertiaryContainer,
      // Additional Material 3 compliant colors
      Colors.red.shade400,
      Colors.pink.shade400,
      Colors.purple.shade400,
      Colors.deepPurple.shade400,
      Colors.indigo.shade400,
      Colors.blue.shade400,
      Colors.lightBlue.shade400,
      Colors.cyan.shade400,
      Colors.teal.shade400,
      Colors.green.shade400,
      Colors.lightGreen.shade400,
      Colors.lime.shade400,
      Colors.yellow.shade400,
      Colors.amber.shade400,
      Colors.orange.shade400,
      Colors.deepOrange.shade400,
    ];
  }

  // Cloud synchronization - Requirement 6: Optional cloud sync management

  Future<void> syncToCloud() async {
    try {
      _isSyncing.value = true;
      await _courseService.syncToCloud();

      // Update last sync date for manual sync
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      _lastSyncDate.value = todayString;
      await _saveLastSyncDate(todayString);

      _showSuccessSnackbar('Courses synced to cloud successfully');
      await loadCourses();
      await loadStatistics();
    } catch (e) {
      _showErrorSnackbar('Sync to Cloud Failed', e.toString());
    } finally {
      _isSyncing.value = false;
    }
  }

  Future<void> syncFromCloud() async {
    try {
      _isSyncing.value = true;
      await _courseService.syncFromCloud();

      _showSuccessSnackbar('Courses synced from cloud successfully');
      await loadCourses();
      await loadStatistics();
    } catch (e) {
      _showErrorSnackbar('Sync from Cloud Failed', e.toString());
    } finally {
      _isSyncing.value = false;
    }
  }

  Future<void> syncCourseToCloud(String courseId) async {
    try {
      await _courseService.syncToCloud();
      _showSuccessSnackbar('Course synced to cloud successfully');
      await loadCourses();
    } catch (e) {
      _showErrorSnackbar('Course Sync Failed', e.toString());
    }
  }

  // Daily auto-sync management - Cloud sync once per day
  Future<void> checkAndPerformDailySync() async {
    if (!_autoSyncEnabled.value) return;

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Check if we've already synced today
    if (_lastSyncDate.value == todayString) {
      return; // Already synced today
    }

    try {
      await syncToCloud();
      _lastSyncDate.value = todayString;
      // Save sync date to storage
      await _saveLastSyncDate(todayString);
    } catch (e) {
      // Don't show error for auto-sync to avoid annoying users
      print('Auto-sync failed: $e');
    }
  }

  Future<void> loadLastSyncDate() async {
    try {
      // Use Get.find to access storage service
      final storage = Get.find<StorageService>();
      final savedDate = storage.read<String>('last_sync_date');
      if (savedDate != null && savedDate.isNotEmpty) {
        _lastSyncDate.value = savedDate;
      }

      // Load auto-sync preference
      final autoSyncPref = storage.read<bool>('auto_sync_enabled');
      if (autoSyncPref != null) {
        _autoSyncEnabled.value = autoSyncPref;
      }
    } catch (e) {
      print('Failed to load last sync date: $e');
    }
  }

  Future<void> _saveLastSyncDate(String date) async {
    try {
      final storage = Get.find<StorageService>();
      storage.write('last_sync_date', date);
    } catch (e) {
      print('Failed to save last sync date: $e');
    }
  }

  void toggleAutoSync(bool enabled) {
    _autoSyncEnabled.value = enabled;
    // Save preference to storage
    try {
      final storage = Get.find<StorageService>();
      storage.write('auto_sync_enabled', enabled);
    } catch (e) {
      print('Failed to save auto-sync preference: $e');
    }
  }

  // Sync status and info methods
  String getSyncStatusMessage() {
    if (!_autoSyncEnabled.value) {
      return 'Auto-sync is disabled';
    }

    if (_lastSyncDate.value.isEmpty) {
      return 'Never synced - sync will happen automatically';
    }

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    if (_lastSyncDate.value == todayString) {
      return 'Synced today - next sync tomorrow';
    } else {
      return 'Last synced: ${_lastSyncDate.value} - sync pending';
    }
  }

  bool needsSync() {
    if (!_autoSyncEnabled.value) return false;

    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return _lastSyncDate.value != todayString;
  }

  // Statistics and analytics - Requirement 8: Statistics calculation for dashboard widgets

  Future<void> loadStatistics() async {
    try {
      final stats = await _courseService.getCourseStatistics();
      _statistics.value = stats;

      // Calculate advanced statistics
      _calculateAdvancedStatistics();

      final teachersList = await _courseService.getAllTeachers();
      _teachers.value = teachersList;

      final classroomsList = await _courseService.getAllClassrooms();
      _classrooms.value = classroomsList;

      _updateUniqueValues();
    } catch (e) {
      print('Failed to load statistics: $e');
      // Set default empty values to prevent UI issues
      _statistics.value = {};
      _advancedStats.value = {};
      _teachers.value = [];
      _classrooms.value = [];
      _semesters.value = [];

      // Show user-friendly error message
      _showErrorSnackbar(
        'Statistics Error',
        'Failed to load course statistics',
      );
    }
  }

  void _calculateAdvancedStatistics() {
    if (_courses.isEmpty) {
      _advancedStats.value = {};
      return;
    }

    final totalCourses = _courses.length;
    final totalCredits = _courses.fold<int>(
      0,
      (sum, course) => sum + course.credits,
    );
    final averageCredits = totalCourses > 0 ? totalCredits / totalCourses : 0.0;

    // Group by teacher (handle null/empty teacher names)
    final teacherCourseCount = <String, int>{};
    for (var course in _courses) {
      final teacherName = course.teacherName.trim();
      if (teacherName.isNotEmpty) {
        teacherCourseCount[teacherName] =
            (teacherCourseCount[teacherName] ?? 0) + 1;
      }
    }

    // Group by classroom (handle null/empty classroom names)
    final classroomUsage = <String, int>{};
    for (var course in _courses) {
      final classroom = course.classroom.trim();
      if (classroom.isNotEmpty) {
        classroomUsage[classroom] = (classroomUsage[classroom] ?? 0) + 1;
      }
    }

    _advancedStats.value = {
      'totalCourses': totalCourses.toDouble(),
      'totalCredits': totalCredits.toDouble(),
      'averageCredits': averageCredits,
      'uniqueTeachers': teacherCourseCount.length.toDouble(),
      'uniqueClassrooms': classroomUsage.length.toDouble(),
      'maxCoursesPerTeacher': teacherCourseCount.values.isNotEmpty
          ? teacherCourseCount.values.reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0,
      'maxClassroomUsage': classroomUsage.values.isNotEmpty
          ? classroomUsage.values.reduce((a, b) => a > b ? a : b).toDouble()
          : 0.0,
    };
  }

  void _updateUniqueValues() {
    // Extract unique semesters from schedules
    final semesterSet = <String>{};
    for (var course in _courses) {
      final schedule = course.schedule.toLowerCase();
      if (schedule.contains('fall')) semesterSet.add('Fall');
      if (schedule.contains('spring')) semesterSet.add('Spring');
      if (schedule.contains('summer')) semesterSet.add('Summer');
      if (schedule.contains('winter')) semesterSet.add('Winter');
    }
    _semesters.value = semesterSet.toList()..sort();
  }

  // Validation methods

  String? validateCourseName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Course name is required';
    }
    if (value.trim().length < 2) {
      return 'Course name must be at least 2 characters';
    }
    return null;
  }

  String? validateTeacherName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Teacher name is required';
    }
    if (value.trim().length < 2) {
      return 'Teacher name must be at least 2 characters';
    }
    return null;
  }

  String? validateClassroom(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Classroom is required';
    }
    return null;
  }

  String? validateSchedule(String? value) {
    // Schedule validation is now handled by structured fields
    // This method is kept for backward compatibility but is no longer used
    return null;
  }

  String? validateCredits(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Credits is required';
    }
    final credits = int.tryParse(value);
    if (credits == null || credits <= 0) {
      return 'Credits must be a positive number';
    }
    if (credits > 20) {
      return 'Credits cannot exceed 20';
    }
    return null;
  }

  // Helper methods - Requirement 7: Error handling with snackbar notifications

  bool _validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  CourseModel _buildCourseFromForm({String? baseId}) {
    // Generate a unique code if not provided to avoid database NOT NULL constraint
    final courseCode = codeController.text.trim().isEmpty
        ? 'AUTO_${DateTime.now().millisecondsSinceEpoch}'
        : codeController.text.trim();

    // Calculate end date if start date and duration are provided
    DateTime? endDate;
    int? durationMonths;
    if (durationController.text.trim().isNotEmpty) {
      durationMonths = int.tryParse(durationController.text.trim());
      if (durationMonths != null && _startDate.value != null) {
        endDate = DateTime(
          _startDate.value!.year,
          _startDate.value!.month + durationMonths,
          _startDate.value!.day,
        );
      }
    }

    // Generate schedule data from multiple schedule entries
    String scheduleString = _generateScheduleString();
    List<int>? scheduleDays;
    String? classTimeStr;
    
    if (_scheduleEntries.isNotEmpty) {
      scheduleDays = _scheduleEntries.map((e) => e.dayOfWeek).toList();
      // For backward compatibility, use the first entry's time
      final firstEntry = _scheduleEntries.first;
      classTimeStr = firstEntry.time24Hour;
    }

    return CourseModel(
      id: baseId ?? _courseService.generateCourseId(),
      userId: _safeAuthController?.user?.uid ?? '',
      name: nameController.text.trim(),
      code: courseCode,
      teacherName: teacherController.text.trim(),
      classroom: classroomController.text.trim(),
      schedule: scheduleString,
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      color: _selectedColor.value != null
          ? '#${_selectedColor.value!.value.toRadixString(16).padLeft(8, '0').substring(2)}'
          : null,
      credits: int.tryParse(creditsController.text) ?? 3,
      createdAt: baseId != null
          ? _selectedCourse.value!.createdAt
          : DateTime.now(),
      updatedAt: DateTime.now(),
      startDate: _startDate.value,
      endDate: endDate,
      durationMonths: durationMonths,
      scheduleDays: scheduleDays,
      classTime: classTimeStr,
      reminderMinutes: _reminderMinutes.value > 0
          ? _reminderMinutes.value
          : null,
    );
  }

  Future<List<String>> _validateCourseData(
    CourseModel course, {
    bool isUpdate = false,
  }) async {
    final errors = <String>[];

    // Basic validation
    final basicErrors = course.validate();
    errors.addAll(basicErrors);

    // Check for duplicate course name
    try {
      final nameExists = await _courseService.courseNameExists(
        course.name,
        excludeId: isUpdate ? course.id : null,
      );
      if (nameExists) {
        errors.add('A course with this name already exists');
      }
    } catch (e) {
      print('Name validation error: $e');
    }

    // Check for duplicate course code if provided
    if (course.code != null && course.code!.isNotEmpty) {
      // Note: Add courseCodeExists method to CourseService if needed
      // For now, we'll skip this validation to avoid errors
      print('Code validation skipped - implement courseCodeExists in service');
    }

    return errors;
  }

  Future<bool> _showDeleteConfirmation() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        icon: Icon(
          Icons.delete_outline,
          color: Get.theme.colorScheme.error,
          size: 28,
        ),
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
              foregroundColor: Get.theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSuccessSnackbar(String message) {
    // Close any existing snackbar first to prevent conflicts
    Get.closeAllSnackbars();

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12, // More Material 3 compliant radius
      icon: Icon(
        Icons.check_circle_outline,
        color: Get.theme.colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _showErrorSnackbar(String title, String message) {
    // Close any existing snackbar first to prevent conflicts
    Get.closeAllSnackbars();

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12, // More Material 3 compliant radius
      icon: Icon(
        Icons.error_outline,
        color: Get.theme.colorScheme.onErrorContainer,
      ),
    );
  }

  // Utility methods

  bool get isFormValid => formKey.currentState?.validate() ?? false;
  bool get hasSelectedCourse => _selectedCourse.value != null;
  bool get hasCourses => _courses.isNotEmpty;
  bool get hasFilteredCourses => _filteredCourses.isNotEmpty;
  bool get isFilterActive =>
      _searchQuery.value.isNotEmpty ||
      _selectedTeacher.value.isNotEmpty ||
      _selectedClassroom.value.isNotEmpty ||
      _selectedSemester.value.isNotEmpty ||
      _minCredits.value > 0 ||
      _maxCredits.value < 20;

  // Additional utility methods for UI compatibility
  Future<bool> updateSelectedCourse() async {
    return await updateCourse();
  }

  Future<bool> deleteSelectedCourse() async {
    if (_selectedCourse.value == null) return false;
    return await deleteCourse(_selectedCourse.value!.id);
  }

  // Export functionality
  Future<void> exportCourses() async {
    try {
      await _courseService.exportCoursesToJson();
      _showSuccessSnackbar('Courses exported successfully');
    } catch (e) {
      _showErrorSnackbar('Export Failed', e.toString());
    }
  }

  // Import functionality
  Future<void> importCourses(String jsonData) async {
    try {
      await _courseService.importCoursesFromJson(jsonData);
      _showSuccessSnackbar('Courses imported successfully');
      await loadCourses();
      await loadStatistics();
    } catch (e) {
      _showErrorSnackbar('Import Failed', e.toString());
    }
  }

  // Notification scheduling methods
  Future<void> _scheduleNotificationsForCourse(CourseModel course) async {
    try {
      // Check if course has schedule information
      if (course.scheduleDays == null ||
          course.scheduleDays!.isEmpty ||
          course.classTime == null ||
          course.classTime!.isEmpty ||
          course.reminderMinutes == null ||
          course.reminderMinutes == 0) {
        print(
          '⚠️ Course ${course.name} does not have complete schedule information',
        );
        return;
      }

      // Get notification service
      final notificationService = Get.find<NotificationService>();

      // Cancel any existing notifications for this course
      await notificationService.cancelCourseReminders(course.id);

      // Schedule new notifications
      await notificationService.scheduleCourseReminders(
        courseId: course.id,
        courseName: course.name,
        classroom: course.classroom,
        scheduleDays: course.scheduleDays!,
        classTime: course.classTime!,
        reminderMinutes: course.reminderMinutes!,
      );

      print('✅ Notifications scheduled for ${course.name}');
    } catch (e) {
      print('❌ Failed to schedule notifications for ${course.name}: $e');
      // Don't throw - notification failure shouldn't prevent course creation
    }
  }

  Future<void> _cancelNotificationsForCourse(String courseId) async {
    try {
      final notificationService = Get.find<NotificationService>();
      await notificationService.cancelCourseReminders(courseId);
      print('✅ Notifications cancelled for course: $courseId');
    } catch (e) {
      print('❌ Failed to cancel notifications for course $courseId: $e');
      // Don't throw - notification failure shouldn't prevent course deletion
    }
  }
}
