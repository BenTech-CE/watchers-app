import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/input.dart';

class RegisterViewJG extends StatefulWidget {
  const RegisterViewJG({super.key});

  @override
  State<RegisterViewJG> createState() => _RegisterViewJGState();
}

class _RegisterViewJGState extends State<RegisterViewJG> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: bgColor,
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          children: [

            // Imagem       
            Container(
              child: Image.network("https://img.elo7.com.br/product/main/3BF0EA2/poster-cartaz-adesivo-decorativo-stranger-things-b-42-5x60cm-stranger-things.jpg", width: double.infinity, fit: BoxFit.contain,),
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.05, 0.4, 0.7, 1],
                )
              ),
            ),

            // Logo
            SafeArea(
              child: Container(
                alignment: AlignmentGeometry.topCenter,
                // Substituir pela logo!
                child: Text("Watchers",style: AppTextStyles.titleLargeBright.copyWith(fontSize: 30),),
              ),
            ),
            
            // Formulário
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(sizeRadius), topRight: Radius.circular(sizeRadius))
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  ],
                ),
              ),
            )      
          ],
        ),
      ),
    );
  }
}