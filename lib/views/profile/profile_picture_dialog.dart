import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';

class ProfilePictureDialog extends StatefulWidget {
  final XFile file;

  const ProfilePictureDialog({super.key, required this.file});

  @override
  State<ProfilePictureDialog> createState() => _ProfilePictureDialogState();
}

class _ProfilePictureDialogState extends State<ProfilePictureDialog> {
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
      title: Text("Alterar Foto de Perfil", style: AppTextStyles.titleLarge.copyWith(fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Deseja confirmar a alteração da sua foto de perfil?", style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),),
          const SizedBox(height: 16),
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: bgColorButton,
                width: 4.0,
              ),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipOval(
                child: kIsWeb ?
                  Image.network(
                    widget.file.path,
                    fit: BoxFit.cover,
                  )
                :
                  Image.file(
                    File(widget.file.path),
                    fit: BoxFit.cover,
                  ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          label: "Cancelar", 
          onPressed: () => Navigator.pop(context), 
          variant: ButtonVariant.secondary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        Button(
          label: "Confirmar", 
          onPressed: () => Navigator.pop(context), 
          variant: ButtonVariant.primary,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
      ],
    );
  }
}