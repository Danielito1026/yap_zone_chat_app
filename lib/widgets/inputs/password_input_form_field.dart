import 'package:flutter/material.dart';

class PasswordInputFormField extends StatefulWidget {
  const PasswordInputFormField({
    super.key,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.textInputAction,
    this.onEditingComplete,
    this.onSaved,
  });
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final void Function(String?)? onSaved;
  @override
  State<PasswordInputFormField> createState() => _PasswordInputFormFieldState();
}

class _PasswordInputFormFieldState extends State<PasswordInputFormField> {
  bool isObscured = true;

  void toggleObscure() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          onPressed: toggleObscure,
          icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      onChanged: widget.onChanged,
      validator: widget.validator,
      obscureText: isObscured,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      onEditingComplete: widget.onEditingComplete,
      autovalidateMode: widget.autovalidateMode,
      onSaved: widget.onSaved,
    );
  }
}
