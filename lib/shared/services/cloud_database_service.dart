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

  // Collection references - nested structure under users/{userId}
  String get _userId => _auth.currentUser?.uid ?? '';

  CollectionReference get _coursesCollection =>
      _firestore.collection('users').doc(_userId).collection('courses');

  CollectionReference get _assignmentsCollection =>
      _firestore.collection('users').doc(_userId).collection('assignments');

  CollectionReference get _assessmentsCollection =>
      _firestore.collection('users').doc(_userId).collection('assessments');

  CollectionReference get _gradesCollection =>
      _firestore.collection('users').doc(_userId).collection('grades');

  CollectionReference get _usersCollection => _firestore.collection('users');

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
        'user_id': _userId,
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

  // Upsert course (create or update)
  Future<String> upsertCourse(Map<String, dynamic> courseData) async {
    try {
      final courseId = courseData['id'] as String?;

      if (courseId == null || courseId.isEmpty) {
        // No ID provided, create new course
        return await createCourse(courseData);
      }

      // Check if course exists in cloud
      final existingDoc = await _coursesCollection.doc(courseId).get();

      if (existingDoc.exists) {
        // Update existing course
        print('🔄 Updating existing course in Firebase: $courseId');
        await _coursesCollection.doc(courseId).set({
          ...courseData,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        }, SetOptions(merge: true));
        print('✅ Course updated in Firebase: $courseId');
        return courseId;
      } else {
        // Create new course with the provided ID
        print('📝 Creating new course in Firebase with ID: $courseId');
        await _coursesCollection.doc(courseId).set({
          ...courseData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        print('✅ Course created in Firebase: $courseId');
        return courseId;
      }
    } catch (e) {
      print('❌ Failed to upsert course in Firebase: $e');
      throw Exception('Failed to upsert course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('No authenticated user');
      }

      print(
        '🔥 Deleting course from Firestore path: users/$_userId/courses/$courseId',
      );
      await _coursesCollection.doc(courseId).delete();
      print('✅ Course document deleted from Firestore');

      // Also delete any duplicate documents with wrong document IDs
      await _deleteCourseDuplicates(courseId);
    } catch (e) {
      print('❌ Firestore delete error: $e');
      throw Exception('Failed to delete course: $e');
    }
  }

  // Delete all duplicate documents for a course (internal helper)
  Future<void> _deleteCourseDuplicates(String courseId) async {
    try {
      final snapshot = await _coursesCollection.get();
      final docsToDelete = <String>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final dataCourseId = data['id'] as String?;

        // If the document contains this course ID but the document ID doesn't match,
        // it's a duplicate that should be deleted
        if (dataCourseId == courseId && doc.id != courseId) {
          docsToDelete.add(doc.id);
        }
      }

      if (docsToDelete.isEmpty) {
        return;
      }

      print(
        '🗑️ Deleting ${docsToDelete.length} duplicate documents for course $courseId',
      );
      final batch = _firestore.batch();
      for (final docId in docsToDelete) {
        print('   🗑️ Deleting duplicate document ID: $docId');
        batch.delete(_coursesCollection.doc(docId));
      }

      await batch.commit();
      print('✅ Deleted ${docsToDelete.length} duplicates');
    } catch (e) {
      print('⚠️ Error deleting duplicates: $e');
      // Don't throw - deletion of main document succeeded
    }
  }

  // Verify course deletion (debug method)
  Future<bool> verifyCourseDeleted(String courseId) async {
    try {
      // Check the main document
      final doc = await _coursesCollection.doc(courseId).get();
      final mainExists = doc.exists;

      // Check for duplicates
      final snapshot = await _coursesCollection.get();
      int duplicateCount = 0;
      for (final d in snapshot.docs) {
        final data = d.data() as Map<String, dynamic>;
        if (data['id'] == courseId) {
          duplicateCount++;
          print('   ⚠️ Found document with course ID $courseId: ${d.id}');
        }
      }

      print('🔍 Course $courseId verification:');
      print('   - Main document exists: $mainExists');
      print('   - Total documents with this ID: $duplicateCount');

      return !mainExists && duplicateCount == 0;
    } catch (e) {
      print('❌ Error verifying course deletion: $e');
      return false;
    }
  }

  // Find duplicate courses (debug method)
  Future<Map<String, List<String>>> findDuplicateCourses() async {
    try {
      final snapshot = await _coursesCollection.get();
      final courseIdMap =
          <String, List<String>>{}; // Maps course ID to list of document IDs

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final courseId = data['id'] as String?;

        if (courseId != null) {
          if (!courseIdMap.containsKey(courseId)) {
            courseIdMap[courseId] = [];
          }
          courseIdMap[courseId]!.add(
            doc.id,
          ); // doc.id is the Firestore document ID
        }
      }

      // Filter to only duplicates (course IDs that have more than one document)
      final duplicates = <String, List<String>>{};
      courseIdMap.forEach((courseId, docIds) {
        if (docIds.length > 1) {
          duplicates[courseId] = docIds;
          print(
            '⚠️ Course ID "$courseId" has ${docIds.length} documents: $docIds',
          );
        }
      });

      if (duplicates.isEmpty) {
        print('✅ No duplicate courses found');
      } else {
        print('⚠️ Found ${duplicates.length} courses with duplicates');
      }

      return duplicates;
    } catch (e) {
      print('❌ Error finding duplicates: $e');
      return {};
    }
  }

  // Clean up all duplicate courses in Firestore
  Future<int> cleanupAllDuplicateCourses() async {
    try {
      print('🧹 Starting cleanup of all duplicate courses...');
      final snapshot = await _coursesCollection.get();
      final courseIdMap = <String, List<String>>{};

      // Build map of course IDs to document IDs
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final courseId = data['id'] as String?;

        if (courseId != null) {
          if (!courseIdMap.containsKey(courseId)) {
            courseIdMap[courseId] = [];
          }
          courseIdMap[courseId]!.add(doc.id);
        }
      }

      int totalDeleted = 0;
      final batch = _firestore.batch();

      // For each course, keep only the document where doc.id == course.id
      courseIdMap.forEach((courseId, docIds) {
        if (docIds.length > 1) {
          print('🔍 Course "$courseId" has ${docIds.length} documents');
          for (final docId in docIds) {
            if (docId != courseId) {
              print('   🗑️ Deleting duplicate: $docId');
              batch.delete(_coursesCollection.doc(docId));
              totalDeleted++;
            } else {
              print('   ✅ Keeping correct document: $docId');
            }
          }
        }
      });

      if (totalDeleted > 0) {
        await batch.commit();
        print('✅ Cleanup complete. Deleted $totalDeleted duplicate documents');
      } else {
        print('✅ No duplicates to clean up');
      }

      return totalDeleted;
    } catch (e) {
      print('❌ Error during cleanup: $e');
      throw Exception('Failed to cleanup duplicates: $e');
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
        'user_id': _userId,
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

  // Upsert assessment (create or update)
  Future<String> upsertAssessment(Map<String, dynamic> assessmentData) async {
    try {
      final assessmentId = assessmentData['id'] as String?;

      if (assessmentId == null || assessmentId.isEmpty) {
        // No ID provided, create new assessment
        return await createAssessment(assessmentData);
      }

      // Check if assessment exists in cloud
      final existingDoc = await _assessmentsCollection.doc(assessmentId).get();

      if (existingDoc.exists) {
        // Update existing assessment
        print('🔄 Updating existing assessment in Firebase: $assessmentId');
        await _assessmentsCollection.doc(assessmentId).set({
          ...assessmentData,
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        }, SetOptions(merge: true));
        print('✅ Assessment updated in Firebase: $assessmentId');
        return assessmentId;
      } else {
        // Create new assessment with the provided ID
        print('📝 Creating new assessment in Firebase with ID: $assessmentId');
        await _assessmentsCollection.doc(assessmentId).set({
          ...assessmentData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'syncStatus': 'synced',
        });
        print('✅ Assessment created in Firebase: $assessmentId');
        return assessmentId;
      }
    } catch (e) {
      print('❌ Failed to upsert assessment in Firebase: $e');
      throw Exception('Failed to upsert assessment: $e');
    }
  }

  // Delete assessment
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('No authenticated user');
      }

      print(
        '🔥 Deleting assessment from Firestore path: users/$_userId/assessments/$assessmentId',
      );
      await _assessmentsCollection.doc(assessmentId).delete();
      print('✅ Assessment document deleted from Firestore');
    } catch (e) {
      print('❌ Firestore delete error: $e');
      throw Exception('Failed to delete assessment: $e');
    }
  }

  // Delete all assessments for a course (cascade delete)
  Future<void> deleteAssessmentsForCourse(String courseId) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('No authenticated user');
      }

      print('🔥 Deleting all assessments for course: $courseId');

      // Query all assessments for this course
      final assessmentsSnapshot = await _assessmentsCollection
          .where('course_id', isEqualTo: courseId)
          .get();

      // Delete each assessment
      final batch = _firestore.batch();
      for (final doc in assessmentsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print(
        '✅ Deleted ${assessmentsSnapshot.docs.length} assessments for course $courseId',
      );
    } catch (e) {
      print('❌ Failed to delete assessments for course: $e');
      throw Exception('Failed to delete assessments for course: $e');
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
      print('🔍 getCloudDataForSync called for: $dataType');
      CollectionReference collection;

      switch (dataType) {
        case 'courses':
          collection = _coursesCollection;
          print('📚 Using courses collection');
          break;
        case 'assignments':
          collection = _assignmentsCollection;
          print('📋 Using assignments collection');
          break;
        case 'assessments':
          collection = _assessmentsCollection;
          print('📝 Using assessments collection');
          break;
        case 'grades':
          collection = _gradesCollection;
          print('📊 Using grades collection');
          break;
        default:
          throw Exception('Invalid data type: $dataType');
      }

      Query query = collection;

      // Filter by date if provided (user filtering is implicit in collection path)
      if (since != null) {
        print('⏰ Filtering by date since: $since');
        query = query.where(
          'updatedAt',
          isGreaterThan: Timestamp.fromDate(since),
        );
      }

      print('🔄 Executing Firestore query for user: $_userId');
      final snapshot = await query.get();
      print('✅ Query returned ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print('ℹ️ No documents found in $dataType collection for current user');
      }

      final results = snapshot.docs.map((doc) {
        final data = {'id': doc.id, ...doc.data() as Map<String, dynamic>};
        print('  📄 Document ${doc.id}: ${data.keys.join(", ")}');
        return data;
      }).toList();

      return results;
    } catch (e, stackTrace) {
      print('❌ Error in getCloudDataForSync: $e');
      print('📍 Stack trace: $stackTrace');
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

  // User profile CRUD operations
  Future<void> saveUserProfile(Map<String, dynamic> profileData) async {
    try {
      if (_userId.isEmpty) {
        throw Exception('No authenticated user');
      }

      print('💾 Saving user profile to Firestore...');
      print('👤 User ID: $_userId');

      await _usersCollection.doc(_userId).set({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ User profile saved to Firestore');
    } catch (e) {
      print('❌ Failed to save user profile to Firestore: $e');
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (_userId.isEmpty) {
        return null;
      }

      print('📥 Fetching user profile from Firestore...');
      final doc = await _usersCollection.doc(_userId).get();

      if (doc.exists) {
        print('✅ User profile retrieved from Firestore');
        final data = doc.data() as Map<String, dynamic>?;

        if (data != null) {
          // Convert Firestore Timestamp fields to ISO 8601 strings
          final convertedData = Map<String, dynamic>.from(data);

          // Convert updatedAt if it's a Timestamp
          if (convertedData['updatedAt'] is Timestamp) {
            convertedData['updatedAt'] =
                (convertedData['updatedAt'] as Timestamp)
                    .toDate()
                    .toIso8601String();
          }

          // Convert createdAt if it's a Timestamp
          if (convertedData['createdAt'] is Timestamp) {
            convertedData['createdAt'] =
                (convertedData['createdAt'] as Timestamp)
                    .toDate()
                    .toIso8601String();
          }

          return convertedData;
        }

        return data;
      }

      print('ℹ️ No user profile found in Firestore');
      return null;
    } catch (e) {
      print('❌ Failed to get user profile from Firestore: $e');
      return null;
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
