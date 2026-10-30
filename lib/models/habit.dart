class Habit {
  final int? habitId;
  final String name;
  final String description;
  final String category;
  final int targetFrequency;
  final String createdAt;
  final bool isActive;

  Habit({
    this.habitId,
    required this.name,
    this.description = '',
    required this.category,
    this.targetFrequency = 1,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, Object?> toMap() {
    final Map<String, Object?> data = {
      'name': name,
      'description': description,
      'category': category,
      'targetFrequency': targetFrequency,
      'createdAt': createdAt,
      'isActive': isActive ? 1 : 0,
    };
    if (habitId != null) {
      data['habitId'] = habitId;
    }
    return data;
  }

  static Habit fromMap(Map<String, Object?> data) {
    return Habit(
      habitId: data['habitId'] as int,
      name: data['name'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      targetFrequency: data['targetFrequency'] as int,
      createdAt: data['createdAt'] as String,
      isActive: (data['isActive'] as int) == 1,
    );
  }
}
