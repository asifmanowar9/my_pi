// Web stub for DatabaseHelper.
// On web, SQLite is not available; Firestore (CloudDatabaseService) is the
// primary data store, so all local-DB methods are safe no-ops / empty returns.

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Compatibility for legacy code paths that still access raw DB directly.
  // On web this is unsupported and should not be used at runtime.
  Future<dynamic> get database async =>
      throw UnsupportedError('Local SQLite database is not available on web.');

  // ── Users ────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllUsers() async => [];
  Future<void> insertOrUpdateUser(Map<String, dynamic> userData) async {}
  Future<Map<String, dynamic>?> getUserById(String userId) async => null;
  Future<void> insertSampleUser(String id, String email, String name) async {}

  // ── Courses ──────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllCourses() async => [];
  Future<void> insertSampleCourse(
    String id,
    String name,
    String teacher,
    String classroom,
    String schedule,
  ) async {}

  // ── Assignments ──────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllAssignments() async => [];

  // ── Grades ───────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllGrades() async => [];

  // ── Table utilities ───────────────────────────────────────────────────────
  Future<int> getTableCount(String tableName) async => 0;
  Future<Map<String, int>> getTableCounts() async => {};

  // ── Course Assignments ────────────────────────────────────────────────────
  Future<int> insertCourseAssignment(Map<String, dynamic> assignment) async =>
      0;
  Future<List<Map<String, dynamic>>> getCourseAssignments(
    String courseId,
  ) async => [];
  Future<Map<String, dynamic>?> getCourseAssignmentById(String id) async =>
      null;
  Future<int> updateCourseAssignment(
    String id,
    Map<String, dynamic> assignment,
  ) async => 0;
  Future<int> deleteCourseAssignment(String id) async => 0;
  Future<int> deleteCourseAssignmentsByCourseId(String courseId) async => 0;
  Future<List<Map<String, dynamic>>> getAllCourseAssignments() async => [];

  // ── Course Grades ─────────────────────────────────────────────────────────
  Future<int> insertCourseGrade(Map<String, dynamic> grade) async => 0;
  Future<Map<String, dynamic>?> getCourseGrade(String courseId) async => null;
  Future<Map<String, dynamic>?> getCourseGradeById(String id) async => null;
  Future<int> updateCourseGrade(String id, Map<String, dynamic> grade) async =>
      0;
  Future<int> deleteCourseGrade(String id) async => 0;
  Future<int> deleteCourseGradeByCourseId(String courseId) async => 0;
  Future<List<Map<String, dynamic>>> getAllCourseGrades() async => [];
  Future<double> calculateOverallGPA() async => 0.0;

  // ── Assessments ───────────────────────────────────────────────────────────
  Future<int> insertAssessment(Map<String, dynamic> assessment) async => 0;
  Future<List<Map<String, dynamic>>> getAssessments(String courseId) async =>
      [];
  Future<List<Map<String, dynamic>>> getAssessmentsByType(
    String courseId,
    String type,
  ) async => [];
  Future<Map<String, dynamic>?> getAssessmentById(String id) async => null;
  Future<int> updateAssessment(
    String id,
    Map<String, dynamic> assessment,
  ) async => 0;
  Future<int> deleteAssessment(String id) async => 0;
  Future<int> deleteAssessmentsByCourseId(String courseId) async => 0;
  Future<List<Map<String, dynamic>>> getAllAssessments([
    String? userId,
  ]) async => [];
  Future<List<Map<String, dynamic>>> getUpcomingAssessments([
    String? userId,
  ]) async => [];

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  Future<void> migrateAnonymousDataToUser(String userId) async {}
  Future<void> close() async {}
}
