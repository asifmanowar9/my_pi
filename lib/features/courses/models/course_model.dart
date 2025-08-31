class CourseModel {
  final String id;
  final String userId;
  final String name;
  final String? code;
  final String teacherName;
  final String classroom;
  final String schedule;
  final String? description;
  final String? color;
  final int credits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? lastSyncAt;

  CourseModel({
    required this.id,
    required this.userId,
    required this.name,
    this.code,
    required this.teacherName,
    required this.classroom,
    required this.schedule,
    this.description,
    this.color,
    this.credits = 3,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lastSyncAt,
  });

  // Getter aliases for UI compatibility
  String get teacher => teacherName;
  DateTime? get syncedAt => lastSyncAt;

  // Factory constructor for creating from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String,
      code: json['code'] as String?,
      teacherName: json['teacher_name'] as String,
      classroom: json['classroom'] as String,
      schedule: json['schedule'] as String,
      description: json['description'] as String?,
      color: json['color'] as String?,
      credits: json['credits'] as int? ?? 3,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isSynced: (json['is_synced'] as int?) == 1,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'code': code,
      'teacher_name': teacherName,
      'classroom': classroom,
      'schedule': schedule,
      'description': description,
      'color': color,
      'credits': credits,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  CourseModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? code,
    String? teacherName,
    String? classroom,
    String? schedule,
    String? description,
    String? color,
    int? credits,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? lastSyncAt,
    DateTime? syncedAt, // Alias for lastSyncAt for UI compatibility
  }) {
    return CourseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherName: teacherName ?? this.teacherName,
      classroom: classroom ?? this.classroom,
      schedule: schedule ?? this.schedule,
      description: description ?? this.description,
      color: color ?? this.color,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: syncedAt ?? lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Validation methods
  bool isValid() {
    return name.trim().isNotEmpty &&
        teacherName.trim().isNotEmpty &&
        classroom.trim().isNotEmpty &&
        schedule.trim().isNotEmpty &&
        credits > 0;
  }

  List<String> validate() {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Course name is required');
    }

    if (teacherName.trim().isEmpty) {
      errors.add('Teacher name is required');
    }

    if (classroom.trim().isEmpty) {
      errors.add('Classroom is required');
    }

    if (schedule.trim().isEmpty) {
      errors.add('Schedule is required');
    }

    if (credits <= 0) {
      errors.add('Credits must be greater than 0');
    }

    return errors;
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, name: $name, teacherName: $teacherName, classroom: $classroom)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseModel &&
        other.id == id &&
        other.name == name &&
        other.teacherName == teacherName &&
        other.classroom == classroom &&
        other.schedule == schedule;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        teacherName.hashCode ^
        classroom.hashCode ^
        schedule.hashCode;
  }
}
