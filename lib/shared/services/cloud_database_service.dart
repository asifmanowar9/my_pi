import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CloudDatabaseService {
  static final CloudDatabaseService _instance =
      CloudDatabaseService._internal();
  factory CloudDatabaseService() => _instance;
  CloudDatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references with user isolation
  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _coursesCollection =>
      _firestore.collection('users').doc(_userId).collection('courses');

  CollectionReference get _assignmentsCollection =>
      _firestore.collection('users').doc(_userId).collection('assignments');

  CollectionReference get _assessmentsCollection =>
      _firestore.collection('users').doc(_userId).collection('assessments');

  CollectionReference get _gradesCollection =>
      _firestore.collection('users').doc(_userId).collection('grades');

  // 6. Offline persistence configuration
  Future<void> enableOfflinePersistence() async {
    try {
      await _firestore.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
      print('✅ Firestore offline persistence enabled');
    } catch (e) {
      print('❌ Firestore persistence error: $e');
    }
  }

  // 2. CRUD operations for courses with user isolation

  // Create course
  Future<String> createCourse(Map<String, dynamic> courseData) async {
    try {
      print('🔥 CloudDatabaseService: Creating course in Firebase');
      print('📝 Course data: ${courseData.keys.toList()}');
      print('👤 User ID: $_userId');

      final docRef = await _coursesCollection.add({
        ...courseData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': _userId,
        'syncStatus': 'synced',
      });

      print('✅ Course created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to create course in Firebase: $e');
      throw Exception('Failed to create course: $e');
    }
  }

  // Read course
  Future<Map<String, dynamic>?> getCourse(String courseId) async {
    try {
      final doc = await _coursesCollection.doc(courseId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get course: $e');
    }
  }

  // Update course
  Future<void> updateCourse(
    String courseId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _coursesCollection.doc(courseId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': 'synced',
      });
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _coursesCollection.doc(courseId).delete();
    } catch (e) {
      throw Exception('Failed to delete course: $e');
    }
  }

  // 2. CRUD operations for assignments with user isolation

  // Create assignment
  Future<String> createAssignment(Map<String, dynamic> assignmentData) async {
    try {
      final docRef = await _assignmentsCollection.add({
        ...assignmentData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': _userId,
        'syncStatus': 'synced',
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create assignment: $e');
    }
  }

  // Read assignment
  Future<Map<String, dynamic>?> getAssignment(String assignmentId) async {
    try {
      final doc = await _assignmentsCollection.doc(assignmentId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  // Update assignment
  Future<void> updateAssignment(
    String assignmentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _assignmentsCollection.doc(assignmentId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': 'synced',
      });
    } catch (e) {
      throw Exception('Failed to update assignment: $e');
    }
  }

  // Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _assignmentsCollection.doc(assignmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  // 2. CRUD operations for grades with user isolation

  // Create grade
  Future<String> createGrade(Map<String, dynamic> gradeData) async {
    try {
      final docRef = await _gradesCollection.add({
        ...gradeData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': _userId,
        'syncStatus': 'synced',
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create grade: $e');
    }
  }

  // Read grade
  Future<Map<String, dynamic>?> getGrade(String gradeId) async {
    try {
      final doc = await _gradesCollection.doc(gradeId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get grade: $e');
    }
  }

  // Update grade
  Future<void> updateGrade(String gradeId, Map<String, dynamic> updates) async {
    try {
      await _gradesCollection.doc(gradeId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': 'synced',
      });
    } catch (e) {
      throw Exception('Failed to update grade: $e');
    }
  }

  // Delete grade
  Future<void> deleteGrade(String gradeId) async {
    try {
      await _gradesCollection.doc(gradeId).delete();
    } catch (e) {
      throw Exception('Failed to delete grade: $e');
    }
  }

  // 2. CRUD operations for assessments with user isolation

  // Create assessment
  Future<String> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      print('🔥 CloudDatabaseService: Creating assessment in Firebase');
      print('📝 Assessment data: ${assessmentData.keys.toList()}');
      print('👤 User ID: $_userId');

      final docRef = await _assessmentsCollection.add({
        ...assessmentData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': _userId,
        'syncStatus': 'synced',
      });

      print('✅ Assessment created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Failed to create assessment in Firebase: $e');
      throw Exception('Failed to create assessment: $e');
    }
  }

  // Read assessment
  Future<Map<String, dynamic>?> getAssessment(String assessmentId) async {
    try {
      final doc = await _assessmentsCollection.doc(assessmentId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get assessment: $e');
    }
  }

  // Update assessment
  Future<void> updateAssessment(
    String assessmentId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _assessmentsCollection.doc(assessmentId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
        'syncStatus': 'synced',
      });
    } catch (e) {
      throw Exception('Failed to update assessment: $e');
    }
  }

  // Delete assessment
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      await _assessmentsCollection.doc(assessmentId).delete();
    } catch (e) {
      throw Exception('Failed to delete assessment: $e');
    }
  }

  // 3. Real-time listeners for data synchronization

  // Listen to courses changes
  Stream<List<Map<String, dynamic>>> listenToCourses() {
    return _coursesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>},
              )
              .toList(),
        );
  }

  // Listen to assignments changes
  Stream<List<Map<String, dynamic>>> listenToAssignments({String? courseId}) {
    Query query = _assignmentsCollection.orderBy('dueDate');

    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList(),
    );
  }

  // Listen to grades changes
  Stream<List<Map<String, dynamic>>> listenToGrades({String? courseId}) {
    Query query = _gradesCollection.orderBy('dateGraded', descending: true);

    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList(),
    );
  }

  // 4. Batch operations for multiple document updates

  Future<void> batchUpdateCourses(
    List<Map<String, dynamic>> coursesData,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final courseData in coursesData) {
        final docRef = _coursesCollection.doc(courseData['id']);
        batch.update(docRef, {
          ...courseData,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update courses: $e');
    }
  }

  Future<void> batchUpdateAssignments(
    List<Map<String, dynamic>> assignmentsData,
  ) async {
    try {
      final batch = _firestore.batch();

      for (final assignmentData in assignmentsData) {
        final docRef = _assignmentsCollection.doc(assignmentData['id']);
        batch.update(docRef, {
          ...assignmentData,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update assignments: $e');
    }
  }

  Future<void> batchUpdateGrades(List<Map<String, dynamic>> gradesData) async {
    try {
      final batch = _firestore.batch();

      for (final gradeData in gradesData) {
        final docRef = _gradesCollection.doc(gradeData['id']);
        batch.update(docRef, {
          ...gradeData,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update grades: $e');
    }
  }

  // 5. Query methods with filtering and pagination

  Future<List<Map<String, dynamic>>> getCoursesPaginated({
    int limit = 10,
    DocumentSnapshot? lastDocument,
    String? orderBy = 'createdAt',
    bool descending = true,
  }) async {
    try {
      Query query = _coursesCollection.orderBy(
        orderBy!,
        descending: descending,
      );

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get paginated courses: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAssignmentsFiltered({
    String? courseId,
    String? status,
    String? priority,
    DateTime? dueDateFrom,
    DateTime? dueDateTo,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _assignmentsCollection;

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (priority != null) {
        query = query.where('priority', isEqualTo: priority);
      }

      if (dueDateFrom != null) {
        query = query.where(
          'dueDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dueDateFrom),
        );
      }

      if (dueDateTo != null) {
        query = query.where(
          'dueDate',
          isLessThanOrEqualTo: Timestamp.fromDate(dueDateTo),
        );
      }

      query = query.orderBy('dueDate').limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get filtered assignments: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGradesFiltered({
    String? courseId,
    String? assessmentType,
    double? minScore,
    double? maxScore,
    DateTime? dateFrom,
    DateTime? dateTo,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _gradesCollection;

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      if (assessmentType != null) {
        query = query.where('assessmentType', isEqualTo: assessmentType);
      }

      if (minScore != null) {
        query = query.where('score', isGreaterThanOrEqualTo: minScore);
      }

      if (maxScore != null) {
        query = query.where('score', isLessThanOrEqualTo: maxScore);
      }

      if (dateFrom != null) {
        query = query.where(
          'dateGraded',
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom),
        );
      }

      if (dateTo != null) {
        query = query.where(
          'dateGraded',
          isLessThanOrEqualTo: Timestamp.fromDate(dateTo),
        );
      }

      query = query.orderBy('dateGraded', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get filtered grades: $e');
    }
  }

  // 7. Data sync methods for local-to-cloud backup

  Future<void> syncLocalDataToCloud(
    List<Map<String, dynamic>> localData,
    String dataType,
  ) async {
    try {
      final batch = _firestore.batch();
      CollectionReference collection;

      switch (dataType) {
        case 'courses':
          collection = _coursesCollection;
          break;
        case 'assignments':
          collection = _assignmentsCollection;
          break;
        case 'grades':
          collection = _gradesCollection;
          break;
        default:
          throw Exception('Invalid data type: $dataType');
      }

      for (final data in localData) {
        final docRef = data['id'] != null
            ? collection.doc(data['id'])
            : collection.doc();

        final syncData = {
          ...data,
          'userId': _userId,
          'syncStatus': 'synced',
          'lastSyncAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        batch.set(docRef, syncData, SetOptions(merge: true));
      }

      await batch.commit();
      print('✅ Synced ${localData.length} $dataType records to cloud');
    } catch (e) {
      throw Exception('Failed to sync $dataType to cloud: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCloudDataForSync(
    String dataType, {
    DateTime? since,
  }) async {
    try {
      CollectionReference collection;

      switch (dataType) {
        case 'courses':
          collection = _coursesCollection;
          break;
        case 'assignments':
          collection = _assignmentsCollection;
          break;
        case 'grades':
          collection = _gradesCollection;
          break;
        default:
          throw Exception('Invalid data type: $dataType');
      }

      Query query = collection;

      if (since != null) {
        query = query.where(
          'updatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      throw Exception('Failed to get cloud data for sync: $e');
    }
  }

  // 8. Conflict resolution for concurrent updates

  Future<void> resolveConflictAndUpdate(
    String documentId,
    String collection,
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
    ConflictResolutionStrategy strategy,
  ) async {
    try {
      CollectionReference collectionRef;

      switch (collection) {
        case 'courses':
          collectionRef = _coursesCollection;
          break;
        case 'assignments':
          collectionRef = _assignmentsCollection;
          break;
        case 'grades':
          collectionRef = _gradesCollection;
          break;
        default:
          throw Exception('Invalid collection: $collection');
      }

      Map<String, dynamic> resolvedData;

      switch (strategy) {
        case ConflictResolutionStrategy.useLocal:
          resolvedData = localData;
          break;
        case ConflictResolutionStrategy.useCloud:
          resolvedData = cloudData;
          break;
        case ConflictResolutionStrategy.useLatest:
          final localTimestamp = localData['updatedAt'] as Timestamp?;
          final cloudTimestamp = cloudData['updatedAt'] as Timestamp?;

          if (localTimestamp != null && cloudTimestamp != null) {
            resolvedData = localTimestamp.compareTo(cloudTimestamp) > 0
                ? localData
                : cloudData;
          } else {
            resolvedData = cloudData;
          }
          break;
        case ConflictResolutionStrategy.merge:
          resolvedData = {...cloudData, ...localData};
          break;
      }

      await collectionRef.doc(documentId).update({
        ...resolvedData,
        'updatedAt': FieldValue.serverTimestamp(),
        'conflictResolved': true,
        'conflictResolvedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Conflict resolved for $collection/$documentId using $strategy');
    } catch (e) {
      throw Exception('Failed to resolve conflict: $e');
    }
  }

  Future<Map<String, dynamic>?> checkForConflicts(
    String documentId,
    String collection,
    Map<String, dynamic> localData,
  ) async {
    try {
      CollectionReference collectionRef;

      switch (collection) {
        case 'courses':
          collectionRef = _coursesCollection;
          break;
        case 'assignments':
          collectionRef = _assignmentsCollection;
          break;
        case 'grades':
          collectionRef = _gradesCollection;
          break;
        default:
          throw Exception('Invalid collection: $collection');
      }

      final cloudDoc = await collectionRef.doc(documentId).get();

      if (!cloudDoc.exists) {
        return null;
      }

      final cloudData = cloudDoc.data() as Map<String, dynamic>;
      final localTimestamp = localData['updatedAt'] as Timestamp?;
      final cloudTimestamp = cloudData['updatedAt'] as Timestamp?;

      if (localTimestamp != null && cloudTimestamp != null) {
        if (localTimestamp.compareTo(cloudTimestamp) < 0) {
          return cloudData;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to check for conflicts: $e');
    }
  }

  // Utility methods
  Future<void> clearUserData() async {
    try {
      final batch = _firestore.batch();

      final courses = await _coursesCollection.get();
      for (final doc in courses.docs) {
        batch.delete(doc.reference);
      }

      final assignments = await _assignmentsCollection.get();
      for (final doc in assignments.docs) {
        batch.delete(doc.reference);
      }

      final grades = await _gradesCollection.get();
      for (final doc in grades.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ User data cleared from cloud');
    } catch (e) {
      throw Exception('Failed to clear user data: $e');
    }
  }
}

enum ConflictResolutionStrategy { useLocal, useCloud, useLatest, merge }
