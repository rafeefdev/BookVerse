class DailyGoal {
  final int targetPages;
  final int targetMinutes;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyGoal({
    required this.targetPages,
    required this.targetMinutes,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyGoal.defaults() => DailyGoal(
    targetPages: 30,
    targetMinutes: 20,
    enabled: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  DailyGoal copyWith({
    int? targetPages,
    int? targetMinutes,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyGoal(
      targetPages: targetPages ?? this.targetPages,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': 1,
    'target_pages': targetPages,
    'target_minutes': targetMinutes,
    'enabled': enabled ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory DailyGoal.fromJson(Map<String, dynamic> json) => DailyGoal(
    targetPages: (json['target_pages'] as int?) ?? 30,
    targetMinutes: (json['target_minutes'] as int?) ?? 20,
    enabled: (json['enabled'] as int?) == 1,
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyGoal &&
          targetPages == other.targetPages &&
          targetMinutes == other.targetMinutes &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(targetPages, targetMinutes, enabled);
}
