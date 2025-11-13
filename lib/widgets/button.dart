import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';

enum ButtonVariant { primary, secondary, inactive }

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final ButtonVariant variant;
  final bool loading;
  final bool disabled;

  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.loading = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: _getForegroundColor(),
          backgroundColor: _getBackgroundColor(),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  Color _getForegroundColor() {
    if (variant == ButtonVariant.primary) {
      return tColorPrimary;
    }
    if (variant == ButtonVariant.secondary) {
      return tColorPrimary;
    }
    if (variant == ButtonVariant.inactive) {
      return Colors.grey.shade400;
    }

    return tColorPrimary;
  }

  Color _getBackgroundColor() {
    if (variant == ButtonVariant.primary) {
      return colorPrimary;
    }

    if (variant == ButtonVariant.secondary) {
      return Colors.grey.shade800;
    }

    if (variant == ButtonVariant.inactive) {
      return Colors.grey.shade900;
    }

    return colorPrimary;
  }
}