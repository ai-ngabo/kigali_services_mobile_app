// email and password validators for forms with regex checks
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final regex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!regex.hasMatch(cleaned)) return 'Enter a valid phone number';
    return null;
  }

  /// Cleans and validates geographic coordinates.
  /// Handles raw numbers and copy-pasted formats like "1.9437° S"
  static String? coordinates(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    
    final input = value.trim().toUpperCase();
    
    // Extract the numeric part (handling decimals and signs)
    final numMatch = RegExp(r'^-?[0-9]*\.?[0-9]+').firstMatch(input);
    if (numMatch == null) return '$label must contain a number';
    
    double? parsed = double.tryParse(numMatch.group(0)!);
    if (parsed == null) return '$label must be a valid number';

    // Handle South and West as negative values
    if (input.contains('S') || input.contains('W')) {
      if (parsed > 0) parsed = -parsed;
    }

    if (label.toLowerCase().contains('latitude')) {
      if (parsed < -90 || parsed > 90) return 'Latitude must be between -90 and 90';
    } else {
      if (parsed < -180 || parsed > 180) return 'Longitude must be between -180 and 180';
    }

    return null;
  }

  /// Utility to parse coordinates from potentially messy input strings
  static double parseCoordinate(String input) {
    final cleanedInput = input.trim().toUpperCase();
    final numMatch = RegExp(r'^-?[0-9]*\.?[0-9]+').firstMatch(cleanedInput);
    if (numMatch == null) return 0.0;
    
    double val = double.tryParse(numMatch.group(0)!) ?? 0.0;
    if (cleanedInput.contains('S') || cleanedInput.contains('W')) {
      if (val > 0) val = -val;
    }
    return val;
  }
}
