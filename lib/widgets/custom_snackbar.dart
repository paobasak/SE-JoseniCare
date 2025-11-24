import 'package:flutter/material.dart';

enum SnackType { success, error, info }

/// Shows a styled, floating SnackBar with an icon and rounded corners.
///
/// - `type` controls the color and icon. Defaults to `info`.
/// - `duration` controls how long the SnackBar is visible.
void showCustomSnackBar(
  BuildContext context,
  String message, {
  SnackType type = SnackType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final Color backgroundColor;
  final IconData icon;

  switch (type) {
    case SnackType.success:
      backgroundColor = const Color(0xFF208A33);
      icon = Icons.check_circle_outline;
      break;
    case SnackType.error:
      backgroundColor = Colors.red.shade700;
      icon = Icons.error_outline;
      break;
    case SnackType.info:
      backgroundColor = Colors.black87;
      icon = Icons.info_outline;
      break;
  }

  // Hide any current snack to avoid stacking
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      backgroundColor: backgroundColor,
      elevation: 6,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}
