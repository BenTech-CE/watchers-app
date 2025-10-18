import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';

enum ButtonVariant { primary, secondary }

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool loading;
  final bool disabled;

  const Button({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
    return tColorPrimary;
  }

  Color _getBackgroundColor() {
    if (variant == ButtonVariant.primary) {
      return colorPrimary;
    }
    return Colors.grey.shade800;
  }
}