import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:watchers/core/theme/texts.dart';

class LoginViewMael extends StatelessWidget {
  const LoginViewMael({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.05, 0.4, 0.7, 1],
                ),
              ),
              child: Image.network(
                "https://cdn.polyspeak.ai/speakmaster/4747b3658f61e5da7f14fddc670a15df.webp",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: LiquidGlass(
                settings: LiquidGlassSettings(
                  blur: 4,
                  glassColor: Colors.white.withAlpha(25),
                  ambientStrength: 0.5,
                  lightIntensity: 1,
                ),
                shape: LiquidRoundedRectangle(
                  borderRadius: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 500,
                  width: double.maxFinite,
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "Para cadastrar-se, preencha os campos abaixo:",
                                style: AppTextStyles.bodyLargeBright,
                              ),
                              Text("Input"),
                              Row(
                                children: [
                                  Text(
                                    "Mostrar senha",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Checkbox(value: showPassword, onChanged: (value) => togglePasswordVisibility(value)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/* 
LIQUID GLASS EFFECT:

 Container(
              alignment: Alignment.bottomCenter,
              child: LiquidGlass(
                settings: LiquidGlassSettings(
                  blur: 4,
                  glassColor: Colors.white.withAlpha(25),
                  ambientStrength: 0.5,
                  lightIntensity: 1,
                ),
                shape: LiquidRoundedRectangle(
                  borderRadius: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 500,
                  width: double.maxFinite,
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      spacing: 16,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                "Para cadastrar-se, preencha os campos abaixo:",
                                style: AppTextStyles.bodyLargeBright,
                              ),
                              Text("Input"),
                              Row(
                                children: [
                                  Text(
                                    "Mostrar senha",
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Checkbox(value: showPassword, onChanged: (value) => togglePasswordVisibility(value)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
*/