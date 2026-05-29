import 'package:flutter/material.dart';

class InputFormField extends StatefulWidget {
  const InputFormField({
    super.key,
    this.labelText,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.textInputAction,
    this.onEditingComplete,
    this.isPasswordField = false,
  });
  final String? labelText;
  final String? hint;
  final Icon? prefixIcon;
  final Icon? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final bool isPasswordField;

  @override
  State<InputFormField> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends State<InputFormField> {
  bool isObscured = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isPasswordField) {
      isObscured = false;
    }
  }

  void toggleObscure() {
    setState(() {
      isObscured = !isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPasswordField
            ? IconButton(
                onPressed: toggleObscure,
                icon: Icon(
                  isObscured ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : widget.suffixIcon,
        hintText: widget.hint,
      ),
      keyboardType: widget.keyboardType,
      autocorrect: widget.autocorrect,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      autovalidateMode: widget.autovalidateMode,
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete,
      obscureText: widget.isPasswordField && isObscured,
    );
  }
}
