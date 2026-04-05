import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? colorText;
  final double? widget;
  final bool showProgress;

  const Button(this.text,
      {super.key,
      this.onPressed,
      this.color,
      this.colorText,
      this.widget,
      this.showProgress = false});

  @override
  Widget build(BuildContext context) =>
    Container(
      height: 46,
      width: widget,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: colorText ?? Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        onPressed: onPressed,
        child: showProgress
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
      ),
    );
}
