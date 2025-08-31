enum AssignmentType { homework, project, quiz, exam, presentation, lab, other }

enum AssignmentStatus { pending, inProgress, completed, overdue, submitted }

enum AssignmentPriority { low, medium, high, urgent }

class Assignment {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final AssignmentType type;
  final AssignmentStatus status;
  final AssignmentPriority priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final DateTime? lastSyncAt;

  const Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.lastSyncAt,
  });

  // toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  // fromJson method
  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      type: AssignmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AssignmentType.other,
      ),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssignmentStatus.pending,
      ),
      priority: AssignmentPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => AssignmentPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.parse(json['lastSyncAt'] as String)
          : null,
    );
  }

  // copyWith method
  Assignment copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    DateTime? dueDate,
    AssignmentType? type,
    AssignmentStatus? status,
    AssignmentPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    DateTime? lastSyncAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  // Validation methods
  bool isValid() {
    return id.isNotEmpty &&
        courseId.isNotEmpty &&
        title.isNotEmpty &&
        description.isNotEmpty;
  }

  String? validateTitle() {
    if (title.isEmpty) return 'Assignment title is required';
    if (title.length < 2) return 'Title must be at least 2 characters';
    if (title.length > 100) return 'Title must be less than 100 characters';
    return null;
  }

  String? validateDescription() {
    if (description.isEmpty) return 'Assignment description is required';
    if (description.length < 5)
      return 'Description must be at least 5 characters';
    if (description.length > 1000)
      return 'Description must be less than 1000 characters';
    return null;
  }

  String? validateCourseId() {
    if (courseId.isEmpty) return 'Course ID is required';
    return null;
  }

  String? validateDueDate() {
    if (dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Due date cannot be in the past';
    }
    return null;
  }

  // Business logic
  bool needsSync() {
    return !isSynced || (lastSyncAt != null && updatedAt.isAfter(lastSyncAt!));
  }

  Assignment markAsSynced() {
    return copyWith(isSynced: true, lastSyncAt: DateTime.now());
  }

  Assignment markAsModified() {
    return copyWith(updatedAt: DateTime.now(), isSynced: false);
  }

  bool isOverdue() {
    return DateTime.now().isAfter(dueDate) &&
        status != AssignmentStatus.completed;
  }

  bool isDueSoon({int daysThreshold = 3}) {
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    return dueDate.isBefore(threshold) && dueDate.isAfter(now);
  }

  Duration timeUntilDue() {
    return dueDate.difference(DateTime.now());
  }

  String get timeUntilDueString {
    final duration = timeUntilDue();
    if (duration.isNegative) return 'Overdue';

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) return '$days day${days > 1 ? 's' : ''} left';
    if (hours > 0) return '$hours hour${hours > 1 ? 's' : ''} left';
    return '$minutes minute${minutes > 1 ? 's' : ''} left';
  }

  Assignment updateStatus() {
    if (isOverdue() && status != AssignmentStatus.completed) {
      return copyWith(status: AssignmentStatus.overdue);
    }
    return this;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Assignment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Assignment(id: $id, title: $title, dueDate: $dueDate, status: ${status.name})';
  }
}
