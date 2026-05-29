import 'package:flutter/material.dart';

class AppSnackbar {
  static SnackBar iconSnackbar(
    BuildContext context, {
    required Icon icon,
    required Text text,
    Color? backgroundColor
  }) {
    return SnackBar(
      elevation: 5,
      content: Row(spacing: 12, children: [icon, text]),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surfaceDim,
      duration: const Duration(seconds: 3),
      persist: false,
      behavior: SnackBarBehavior.floating,
    );
  }
}
