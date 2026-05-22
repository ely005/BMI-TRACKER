class BMIValidator {
  static const double maxHeightCm = 999.99;
  static const double maxWeightKg = 999.99;
  static const double maxBmiValue = 99.99;

  static String? validateHeight(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Height is required';
    }
    final double? height = double.tryParse(text);
    if (height == null || height <= 0) {
      return 'Height must be a positive number';
    }
    if (height > maxHeightCm) {
      return 'Height must be $maxHeightCm cm or less';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Weight is required';
    }
    final double? weight = double.tryParse(text);
    if (weight == null || weight <= 0) {
      return 'Weight must be a positive number';
    }
    if (weight > maxWeightKg) {
      return 'Weight must be $maxWeightKg kg or less';
    }
    return null;
  }

  static String? validateBmi(double bmi) {
    if (bmi.isNaN || bmi.isInfinite || bmi <= 0) {
      return 'BMI is invalid';
    }
    if (bmi > maxBmiValue) {
      return 'BMI must be $maxBmiValue or less';
    }
    return null;
  }

  static String? validateAge(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final int? age = int.tryParse(text);
    if (age == null || age <= 0) {
      return 'Age must be a valid positive number';
    }
    return null;
  }
}
