class Course {
  final String id;
  final String name;
  final String teacherName;
  final String classroom;
  final String schedule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? lastSyncAt;

  const Course({
    required this.id,
    required this.name,
    required this.teacherName,
    required this.classroom,
    required this.schedule,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lastSyncAt,
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teacherName': teacherName,
      'classroom': classroom,
      'schedule': schedule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  // fromJson method
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      teacherName: json['teacherName'] as String,
      classroom: json['classroom'] as String,
      schedule: json['schedule'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
    );
  }

  // copyWith method
  Course copyWith({
    String? id,
    String? name,
    String? teacherName,
    String? classroom,
    String? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? lastSyncAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherName: teacherName ?? this.teacherName,
      classroom: classroom ?? this.classroom,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        teacherName.isNotEmpty &&
        classroom.isNotEmpty &&
        schedule.isNotEmpty;
  }

  String? validateName() {
    if (name.isEmpty) return 'Course name is required';
    if (name.length < 2) return 'Course name must be at least 2 characters';
    if (name.length > 100)
      return 'Course name must be less than 100 characters';
    return null;
  }

  String? validateTeacherName() {
    if (teacherName.isEmpty) return 'Teacher name is required';
    if (teacherName.length < 2)
      return 'Teacher name must be at least 2 characters';
    if (teacherName.length > 50)
      return 'Teacher name must be less than 50 characters';
    return null;
  }

  String? validateClassroom() {
    if (classroom.isEmpty) return 'Classroom is required';
    if (classroom.length > 20)
      return 'Classroom must be less than 20 characters';
    return null;
  }

  String? validateSchedule() {
    if (schedule.isEmpty) return 'Schedule is required';
    if (schedule.length > 100)
      return 'Schedule must be less than 100 characters';
    return null;
  }

  // Business logic
  bool needsSync() {
    return !isSynced || (lastSyncAt != null && updatedAt.isAfter(lastSyncAt!));
  }

  Course markAsSynced() {
    return copyWith(isSynced: true, lastSyncAt: DateTime.now());
  }

  Course markAsModified() {
    return copyWith(updatedAt: DateTime.now(), isSynced: false);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, name: $name, teacherName: $teacherName, classroom: $classroom)';
  }
}
