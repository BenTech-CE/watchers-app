import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';

class TextInputWidget extends StatefulWidget {
  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool autocorrect;
  final bool isPassword;

  const TextInputWidget({
    super.key,
    required this.label,
    this.hint = "",
    this.icon,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autocorrect = false,
    this.isPassword = false,
  });

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  bool showPassword = true;
  bool _isFocused = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: colorPrimary.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (mounted) {
            setState(() {
              _isFocused = hasFocus;
            });
          }
        },
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          autocorrect: widget.autocorrect,
          obscureText: widget.isPassword ? showPassword : false,
          validator: widget.validator,
          autovalidateMode: _autovalidateMode,
          onChanged: (value) {
            // Após a primeira validação (erro), revalida automaticamente
            if (_autovalidateMode == AutovalidateMode.disabled && widget.validator != null) {
              final error = widget.validator!(value);
              if (error != null) {
                setState(() {
                  _autovalidateMode = AutovalidateMode.onUserInteraction;
                });
              }
            }
          },
          decoration: InputDecoration(
            label: Text(widget.label),
            hint: Text(
              widget.hint,
              style: AppTextStyles.labelMedium.copyWith(
                color: tColorQuarternary,
              ),
            ),
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      showPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: bColorPrimary, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: bColorPrimary, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorPrimary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade400, width: 2.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2.0),
            ),
            errorStyle: AppTextStyles.labelSmall.copyWith(
              color: Colors.red.shade400,
              height: 0.8,
            ),
            filled: true,
            fillColor: tiColorPrimary,
          ),
        ),
      ),
    );
  }
}
