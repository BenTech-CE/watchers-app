import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';

class YesNoDialog extends StatefulWidget {
  final String title;
  final String content;
  final String cta;
  bool loading;

  YesNoDialog({super.key, required this.title, required this.content, required this.cta, this.loading = false});

  @override
  State<YesNoDialog> createState() => _YesNoDialogState();
}

class _YesNoDialogState extends State<YesNoDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(16),
      titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      backgroundColor: const Color.fromARGB(255, 30, 30, 30), // Fundo escuro
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordas arredondadas
      ),
      title: Text(widget.title, style: AppTextStyles.titleLarge.copyWith(fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.content, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),),
        ],
      ),
      actions: [
        Button(
          label: "Cancelar", 
          onPressed: () => Navigator.pop(context, false), 
          variant: ButtonVariant.secondary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          disabled: widget.loading,
        ),
        Button(
          label: widget.cta, 
          onPressed: () => Navigator.pop(context, true), 
          variant: ButtonVariant.primary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          loading: widget.loading,
          disabled: widget.loading,
        ),
      ],
    );
  }
}