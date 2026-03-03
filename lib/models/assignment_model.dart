class Assignment {
  final int id;
  final String documentId;
  final String title;
  final int? courseId;
  final String courseName;
  final String instructions;
  final DateTime dueDate;
  final int maxPoints;
  final int passingGrade;
  final bool allowLateSubmission;
  final String? attachmentUrl;
  final DateTime createdAt;

  const Assignment({
    required this.id,
    required this.documentId,
    required this.title,
    required this.courseId,
    required this.courseName,
    required this.instructions,
    required this.dueDate,
    this.maxPoints = 100,
    this.passingGrade = 0,
    required this.allowLateSubmission,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    final data = _extractDataNode(json);
    final courseNode = data['course'];
    final courseData = _extractDataNodeIfMap(courseNode);

    final resolvedCourseId = _toIntNullable(data['course']) ??
        _toIntNullable(data['courseId']) ??
        _toIntNullable(courseData?['id']);

    final resolvedCourseName = (courseData?['title'] ??
            courseData?['name'] ??
            data['courseName'] ??
            data['course_name'] ??
            '')
        .toString();

    final dueDate = _toDateTime(data['due_date'] ?? data['dueDate']) ??
        DateTime.now().add(const Duration(days: 7));

    return Assignment(
      id: _toInt(data['id']),
      documentId: (data['documentId'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      courseId: resolvedCourseId,
      courseName: resolvedCourseName.trim().isEmpty
          ? 'Non spécifié'
          : resolvedCourseName,
      instructions: _descriptionToText(
        data['description'] ?? data['instructions'],
      ),
      dueDate: dueDate,
      maxPoints: _toInt(data['max_points'] ?? data['maxPoints'], fallback: 100),
      passingGrade: _toInt(
          data['passing_score'] ??
              data['passing_grade'] ??
              data['passingGrade'],
          fallback: 0),
      allowLateSubmission: _toBool(
        data['allow_late_submission'] ?? data['allowLateSubmission'],
      ),
      attachmentUrl: _toNullableString(
        data['attachment_url'] ?? data['attachmentUrl'] ?? data['attachment'],
      ),
      createdAt: _toDateTime(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'title': title,
      'course': courseId,
      'description': instructions,
      'due_date': dueDate.toIso8601String(),
      'max_points': maxPoints,
      'passing_score': passingGrade,
      'allow_late_submission': allowLateSubmission,
      'attachment': attachmentUrl,
    };
  }

  Assignment copyWith({
    int? id,
    String? documentId,
    String? title,
    int? courseId,
    String? courseName,
    String? instructions,
    DateTime? dueDate,
    int? maxPoints,
    int? passingGrade,
    bool? allowLateSubmission,
    String? attachmentUrl,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      instructions: instructions ?? this.instructions,
      dueDate: dueDate ?? this.dueDate,
      maxPoints: maxPoints ?? this.maxPoints,
      passingGrade: passingGrade ?? this.passingGrade,
      allowLateSubmission: allowLateSubmission ?? this.allowLateSubmission,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

Map<String, dynamic> _extractDataNode(Map<String, dynamic> json) {
  if (json.containsKey('data')) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return _extractDataNode(data);
    }
  }

  final attributes = json['attributes'];
  if (attributes is Map<String, dynamic>) {
    return {
      'id': json['id'] ?? attributes['id'],
      ...attributes,
    };
  }

  return json;
}

Map<String, dynamic>? _extractDataNodeIfMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _extractDataNode(value);
  }
  return null;
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

int? _toIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String? _toNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return text;
}

String _descriptionToText(dynamic value) {
  if (value == null) return '';

  if (value is String) {
    return value;
  }

  if (value is List) {
    final buffer = StringBuffer();

    for (final block in value) {
      if (block is! Map) continue;
      final children = block['children'];
      if (children is! List) continue;

      for (final child in children) {
        if (child is! Map) continue;
        final text = child['text']?.toString() ?? '';
        if (text.trim().isEmpty) continue;

        if (buffer.isNotEmpty) {
          buffer.writeln();
        }
        buffer.write(text);
      }
    }

    return buffer.toString();
  }

  return value.toString();
}
