import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

InputDecoration kInputDec(
  String hint, {
  IconData? icon,
  Widget? suffix,
  String? errorText,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[500]),
    filled: true,
    fillColor: kInputBg,
    errorText: errorText,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: kOrange, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
    errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    prefixIcon: icon != null ? Icon(icon, color: kOrange) : null,
    suffixIcon: suffix,
  );
}

Widget kGradientButton({
  required String label,
  VoidCallback? onPressed,
  IconData? icon,
}) {
  final bool isEnabled = onPressed != null;
  return Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      gradient: isEnabled
          ? const LinearGradient(
              colors: [Color(0xFFFF9455), Color(0xFFE0632B)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
      color: isEnabled ? null : const Color(0xFF2A2E3D),
      borderRadius: BorderRadius.circular(16),
      boxShadow: isEnabled
          ? [
              BoxShadow(
                color: kOrange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: Colors.grey[500],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isEnabled ? Colors.white : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 10),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEnabled ? Colors.white : Colors.grey[500],
            ),
          ),
        ],
      ),
    ),
  );
}
