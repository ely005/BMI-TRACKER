class BmiHelper {
  static double calculateBmi(double weightKg, double heightCm) {
    if (weightKg <= 0 || heightCm <= 0) {
      return 0;
    }
    final double heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    }
    if (bmi <= 24.9) {
      return 'Normal';
    }
    if (bmi <= 29.9) {
      return 'Overweight';
    }
    return 'Obese';
  }

  static String getBmiMessage(double bmi) {
    if (bmi < 18.5) {
      return 'You are below the normal range. Consider improving nutrition.';
    }
    if (bmi <= 24.9) {
      return 'Great! Your BMI is in the normal range.';
    }
    if (bmi <= 29.9) {
      return 'You are above the normal range. Regular exercise may help.';
    }
    return 'Your BMI is high. Consult a healthcare professional if needed.';
  }
}
