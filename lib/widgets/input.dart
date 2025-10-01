import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';

class TextInputWidget extends StatelessWidget {
  final String label;
  final String hint; 
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool autocorrect; 
  final bool isPassword;
  
  const TextInputWidget({
    required this.label, 
    this.hint = "", 
    this.icon, 
    required this.controller, 
    this.keyboardType = TextInputType.text, 
    this.validator,
    this.autocorrect = false,
    this.isPassword = false
  });
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        autocorrect: autocorrect,
        obscureText: isPassword,
        validator: validator,
        decoration: InputDecoration(
          label: Text(label, style: AppTextStyles.labelLarge,),
          hint: Text(hint, style: AppTextStyles.labelMedium,),
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorPrimary,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: tiColorPrimary
        ),
      ),
    );
  }
}