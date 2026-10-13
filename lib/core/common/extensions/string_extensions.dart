final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get capitalizeWords =>
      split(' ').map((word) => word.capitalize).join(' ');

  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';

  bool get isBlank => trim().isEmpty;

  bool get isValidEmail => _emailPattern.hasMatch(this);
}
