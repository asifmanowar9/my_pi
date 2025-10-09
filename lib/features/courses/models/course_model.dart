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

  // New fields for course duration
  final DateTime? startDate;
  final DateTime? endDate;
  final int? durationMonths;
  final String status; // 'active', 'completed', 'upcoming'

  // New fields for class schedule and notifications
  final List<int>? scheduleDays; // Day of week: 1 (Monday) to 7 (Sunday)
  final String? classTime; // Format: "HH:mm" (24-hour format)
  final int?
  reminderMinutes; // Minutes before class to send notification (10 or 15)

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
    this.startDate,
    this.endDate,
    this.durationMonths,
    String? status,
    this.scheduleDays,
    this.classTime,
    this.reminderMinutes,
  }) : status = status ?? _calculateStatus(startDate, endDate);

  // Calculate status based on dates
  static String _calculateStatus(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return 'active';

    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 'upcoming';
    } else if (now.isAfter(endDate)) {
      return 'completed';
    } else {
      return 'active';
    }
  }

  // Getter aliases for UI compatibility
  String get teacher => teacherName;
  DateTime? get syncedAt => lastSyncAt;

  // Helper methods for course status
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isUpcoming => status == 'upcoming';

  // Calculate days remaining until course ends
  int? get daysRemaining {
    if (endDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  // Get progress percentage (0-100)
  double? get progressPercentage {
    if (startDate == null || endDate == null) return null;

    final now = DateTime.now();
    final totalDuration = endDate!.difference(startDate!).inDays;
    if (totalDuration <= 0) return 100.0;

    final elapsed = now.difference(startDate!).inDays;
    if (elapsed < 0) return 0.0;
    if (elapsed > totalDuration) return 100.0;

    return (elapsed / totalDuration * 100).clamp(0.0, 100.0);
  }

  // Format duration as readable string
  String get durationText {
    if (durationMonths != null) {
      if (durationMonths == 1) return '1 month';
      return '$durationMonths months';
    }
    if (startDate != null && endDate != null) {
      final months = ((endDate!.difference(startDate!).inDays) / 30).round();
      if (months == 1) return '1 month';
      return '$months months';
    }
    return 'Not set';
  }

  // Helper methods for schedule display
  String get scheduleDaysText {
    if (scheduleDays == null || scheduleDays!.isEmpty) return 'No days set';

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedDays = List<int>.from(scheduleDays!)..sort();
    return sortedDays.map((day) => dayNames[day - 1]).join(', ');
  }

  String get classTimeText {
    if (classTime == null || classTime!.isEmpty) return 'No time set';

    // Convert 24-hour format to 12-hour format
    try {
      final parts = classTime!.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');

      return '$displayHour:$displayMinute $period';
    } catch (e) {
      return classTime ?? 'Invalid time';
    }
  }

  String get reminderText {
    if (reminderMinutes == null) return 'No reminder';
    return '$reminderMinutes min before class';
  }

  bool get hasSchedule {
    return scheduleDays != null &&
        scheduleDays!.isNotEmpty &&
        classTime != null &&
        classTime!.isNotEmpty;
  }

  // Factory constructor for creating from JSON
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final startDate = json['start_date'] != null
        ? DateTime.parse(json['start_date'] as String)
        : null;
    final endDate = json['end_date'] != null
        ? DateTime.parse(json['end_date'] as String)
        : null;

    // Parse schedule days from comma-separated string
    List<int>? scheduleDays;
    if (json['schedule_days'] != null && json['schedule_days'] != '') {
      try {
        scheduleDays = (json['schedule_days'] as String)
            .split(',')
            .map((e) => int.parse(e.trim()))
            .toList();
      } catch (e) {
        scheduleDays = null;
      }
    }

    return CourseModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Course',
      code: json['code'] as String?,
      teacherName: json['teacher_name'] as String? ?? 'Unknown',
      classroom: json['classroom'] as String? ?? 'TBA',
      schedule: json['schedule'] as String? ?? 'Not scheduled',
      description: json['description'] as String?,
      color: json['color'] as String?,
      credits: json['credits'] as int? ?? 3,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      isSynced: (json['is_synced'] as int?) == 1,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      startDate: startDate,
      endDate: endDate,
      durationMonths: json['duration_months'] as int?,
      status: json['status'] as String?,
      scheduleDays: scheduleDays,
      classTime: json['class_time'] as String?,
      reminderMinutes: json['reminder_minutes'] as int?,
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
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'duration_months': durationMonths,
      'status': status,
      'schedule_days': scheduleDays?.join(','),
      'class_time': classTime,
      'reminder_minutes': reminderMinutes,
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
    DateTime? startDate,
    DateTime? endDate,
    int? durationMonths,
    String? status,
    List<int>? scheduleDays,
    String? classTime,
    int? reminderMinutes,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      durationMonths: durationMonths ?? this.durationMonths,
      status: status ?? this.status,
      scheduleDays: scheduleDays ?? this.scheduleDays,
      classTime: classTime ?? this.classTime,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
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
