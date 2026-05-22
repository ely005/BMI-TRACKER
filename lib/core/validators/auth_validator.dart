class AuthValidator {
  static String? validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Name is required';
    }
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Email is required';
    }
    const String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
    final RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) {
      return 'Password is required';
    }
    if (text.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
