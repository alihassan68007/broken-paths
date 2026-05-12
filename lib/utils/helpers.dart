import 'dart:async';

class Helpers {
  /// Simple delay function for async operations
  static Future<void> delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Capitalizes the first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Formats a large number with commas (e.g., 1000 -> 1,000)
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
