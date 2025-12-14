import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';

class UnsavedChangesDialog extends StatefulWidget {
  const UnsavedChangesDialog({super.key});

  @override
  State<UnsavedChangesDialog> createState() => _UnsavedChangesDialogState();
}

class _UnsavedChangesDialogState extends State<UnsavedChangesDialog> {
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
      title: Text("Alterações Não Salvas", style: AppTextStyles.titleLarge.copyWith(fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Você possui alterações não salvas. Deseja descartar suas alterações?", style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),),
        ],
      ),
      actions: [
        Button(
          label: "Voltar", 
          onPressed: () => Navigator.pop(context, false), 
          variant: ButtonVariant.secondary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        Button(
          label: "Descartar", 
          onPressed: () => Navigator.pop(context, true), 
          variant: ButtonVariant.primary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ],
    );
  }
}