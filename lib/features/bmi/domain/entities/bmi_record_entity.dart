class BmiRecordEntity {
  const BmiRecordEntity({
    required this.id,
    this.userId,
    required this.heightCm,
    required this.weightKg,
    required this.bmiValue,
    required this.category,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? userId;
  final double heightCm;
  final double weightKg;
  final double bmiValue;
  final String category;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BmiRecordEntity copyWith({
    String? id,
    String? userId,
    double? heightCm,
    double? weightKg,
    double? bmiValue,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BmiRecordEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmiValue: bmiValue ?? this.bmiValue,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
