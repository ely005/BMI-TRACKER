import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/core/validators/bmi_validator.dart';

class UpdateBmiRequest {
  const UpdateBmiRequest({
    required this.id,
    required this.heightCm,
    required this.weightKg,
    this.notes,
  });

  final String id;
  final double heightCm;
  final double weightKg;
  final String? notes;

  double get bmiValue => BmiHelper.calculateBmi(weightKg, heightCm);

  String get category => BmiHelper.getBmiCategory(bmiValue);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'bmi_value': bmiValue,
      'category': category,
      'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
    };
  }

  String? validate() {
    if (id.trim().isEmpty) {
      return 'Record id is required';
    }

    final String? heightError = BMIValidator.validateHeight(
      heightCm.toString(),
    );
    if (heightError != null) {
      return heightError;
    }

    final String? weightError = BMIValidator.validateWeight(
      weightKg.toString(),
    );
    if (weightError != null) {
      return weightError;
    }

    final String? bmiError = BMIValidator.validateBmi(bmiValue);
    if (bmiError != null) {
      return bmiError;
    }

    return null;
  }
}
