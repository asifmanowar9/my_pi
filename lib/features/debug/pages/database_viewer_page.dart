import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/database/database_helper_clean.dart';
import '../../auth/controllers/auth_controller.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  final DatabaseHelper _dbHelper = Get.find<DatabaseHelper>();
  AuthController? _authController;
  bool _isLoading = true;
  String _status = 'Initializing database...';
  Map<String, int> _tableCounts = {};
  String _selectedTable = '';
  List<Map<String, dynamic>> _tableData = [];
  bool _loadingTableData = false;
  Map<String, dynamic>? _currentUserData;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      // Try to get existing controller or create new one
      if (Get.isRegistered<AuthController>()) {
        _authController = Get.find<AuthController>();
      } else {
        _authController = Get.put(AuthController(), permanent: true);
        // Wait a bit for controller to initialize
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Error initializing AuthController: $e');
      // Continue without AuthController
    }
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await _dbHelper.database;

      // Check if current user is in database
      if (_authController?.isAuthenticated == true) {
        final currentUser = _authController!.user!;
        _currentUserData = await _dbHelper.getUserById(currentUser.uid);

        // If user not in database, save them now
        if (_currentUserData == null) {
          final userData = {
            'id': currentUser.uid,
            'email': currentUser.email ?? '',
            'name': currentUser.displayName ?? 'User',
            'profile_picture': currentUser.photoURL,
          };
          await _dbHelper.insertOrUpdateUser(userData);
          _currentUserData = await _dbHelper.getUserById(currentUser.uid);
        }
      }

      final counts = await _dbHelper.getTableCounts();
      setState(() {
        _status = 'Database connected successfully!';
        _tableCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Database error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() {
      _selectedTable = tableName;
      _loadingTableData = true;
      _tableData = [];
    });

    try {
      List<Map<String, dynamic>> data;
      switch (tableName) {
        case 'users':
          data = await _dbHelper.getAllUsers();
          break;
        case 'courses':
          data = await _dbHelper.getAllCourses();
          break;
        case 'assignments':
          data = await _dbHelper.getAllAssignments();
          break;
        case 'grades':
          data = await _dbHelper.getAllGrades();
          break;
        default:
          data = [];
      }

      setState(() {
        _tableData = data;
        _loadingTableData = false;
      });
    } catch (e) {
      setState(() {
        _loadingTableData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading $tableName data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            _status.contains('error')
                                ? Icons.error
                                : Icons.check_circle,
                            color: _status.contains('error')
                                ? Colors.red
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_status)),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLoading &&
                !_status.contains('error') &&
                (_authController?.isAuthenticated == true))
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Current User',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _initializeDatabase,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_currentUserData != null) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage:
                                _currentUserData!['profile_picture'] != null
                                ? NetworkImage(
                                    _currentUserData!['profile_picture'],
                                  )
                                : null,
                            child: _currentUserData!['profile_picture'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(_currentUserData!['name'] ?? 'No name'),
                          subtitle: Text(
                            _currentUserData!['email'] ?? 'No email',
                          ),
                          trailing: Chip(
                            label: const Text('In Database'),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ),
                      ] else ...[
                        const ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.warning, color: Colors.orange),
                          title: Text('User not found in database'),
                          subtitle: Text('Try refreshing to sync user data'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (!_isLoading && !_status.contains('error'))
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Database Tables',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text('users'),
                        subtitle: Text(
                          'User account information (${_tableCounts['users'] ?? 0} records)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _loadTableData('users'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('courses'),
                        subtitle: Text(
                          'Course information (${_tableCounts['courses'] ?? 0} records)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _loadTableData('courses'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.assignment),
                        title: const Text('assignments'),
                        subtitle: Text(
                          'Assignment tracking (${_tableCounts['assignments'] ?? 0} records)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _loadTableData('assignments'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.grade),
                        title: const Text('grades'),
                        subtitle: Text(
                          'Grade records (${_tableCounts['grades'] ?? 0} records)',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _loadTableData('grades'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedTable.isNotEmpty)
              SizedBox(
                height: 400, // Fixed height to prevent overflow
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$_selectedTable Data',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: () => _loadTableData(_selectedTable),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _loadingTableData
                              ? const Center(child: CircularProgressIndicator())
                              : _tableData.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No data in $_selectedTable table',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _tableData.length,
                                  itemBuilder: (context, index) {
                                    final record = _tableData[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ExpansionTile(
                                        title: Text(
                                          record['id']?.toString() ?? 'No ID',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        subtitle: Text(
                                          _getRecordSubtitle(record),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: record.entries.map((
                                                entry,
                                              ) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        width: 120,
                                                        child: Text(
                                                          '${entry.key}:',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          entry.value
                                                                  ?.toString() ??
                                                              'null',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleData,
        tooltip: 'Add Sample Data',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addSampleData() async {
    try {
      // Add sample user
      await _dbHelper.insertSampleUser(
        'user_${DateTime.now().millisecondsSinceEpoch}',
        'sample@example.com',
        'Sample User',
      );

      // Add sample course
      await _dbHelper.insertSampleCourse(
        'course_${DateTime.now().millisecondsSinceEpoch}',
        'Introduction to Flutter',
        'Dr. Smith',
        'Room 101',
        'Mon/Wed/Fri 10:00 AM',
      );

      // Refresh all data including current user
      await _initializeDatabase();

      // If a table is currently selected, refresh its data
      if (_selectedTable.isNotEmpty) {
        _loadTableData(_selectedTable);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding sample data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRecordSubtitle(Map<String, dynamic> record) {
    switch (_selectedTable) {
      case 'users':
        return record['email']?.toString() ?? '';
      case 'courses':
        return record['name']?.toString() ?? '';
      case 'assignments':
        return record['title']?.toString() ?? '';
      case 'grades':
        return record['title']?.toString() ?? '';
      default:
        return '';
    }
  }
}
