import 'package:flutter/material.dart';

Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
  required String label,
  required String? Function(String?)? validate,
  Function? onTap,
  IconData? prefix,
  IconData? suffix,
  bool isPassword = false,
  VoidCallback? suffixPressed,
  ValueChanged<String>? onSubmit,
  ValueChanged<String>? onChange,
  bool isClickable = true,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: type,
    obscureText: isPassword,
    validator: validate,
    onTap: onTap as void Function()?,
    onFieldSubmitted: onSubmit,
    onChanged: onChange,
    enabled: isClickable,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: prefix != null ? Icon(prefix) : null,
      suffixIcon: suffix != null
          ? IconButton(onPressed: suffixPressed, icon: Icon(suffix))
          : null,
      border: OutlineInputBorder(),
    ),
  );
}
