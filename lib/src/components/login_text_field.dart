import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final String hintText;
  final BuildContext context;
  final TextEditingController? controller;
  final bool obscure;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  const LoginTextField(
    this.context,
    this.hintText, {
    super.key,
    this.controller,
    this.obscure = false,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.nextFocus,
  });
  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(splashColor: Colors.transparent),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 22, color: Color(0xFFbdc6cf)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            hintText: hintText,
            contentPadding: const EdgeInsets.only(left: 14, bottom: 8, top: 8),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
}
