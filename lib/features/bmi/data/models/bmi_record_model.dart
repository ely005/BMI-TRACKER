import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';

class BmiRecordModel extends BmiRecordEntity {
  const BmiRecordModel({
    required super.id,
    super.userId,
    required super.heightCm,
    required super.weightKg,
    required super.bmiValue,
    required super.category,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  factory BmiRecordModel.fromJson(Map<String, dynamic> json) {
    return BmiRecordModel(
      id: (json['id'] ?? '').toString(),
      userId: _nullableString(json['user_id'] ?? json['userId']),
      heightCm: _toDouble(json['height_cm'] ?? json['height']),
      weightKg: _toDouble(json['weight_kg'] ?? json['weight']),
      bmiValue: _toDouble(json['bmi_value'] ?? json['bmi']),
      category: (json['category'] ?? json['bmi_category'] ?? '').toString(),
      notes: _nullableString(json['notes']),
      createdAt: _toDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _toDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }

  factory BmiRecordModel.fromEntity(BmiRecordEntity entity) {
    return BmiRecordModel(
      id: entity.id,
      userId: entity.userId,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      bmiValue: entity.bmiValue,
      category: entity.category,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi_value': bmiValue,
      'category': category,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static double _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }
    return text;
  }
}
