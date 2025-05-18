import 'package:flutter/material.dart';

class ButtonApp extends StatelessWidget {
  final String? text;
  final Color? color;
  final VoidCallback? onPressed;

  const ButtonApp({
    super.key,
    this.text,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text ?? 'Login',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
