class InputHelper {
  static String trim(String value) => value.trim();

  static bool isEmpty(String value) => trim(value).isEmpty;

  static double? toDouble(String value) {
    return double.tryParse(trim(value));
  }
}
