import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/input.dart';
import 'package:flutter_svg/flutter_svg.dart';

// class LoginViewMael extends StatelessWidget {
//   const LoginViewMael({super.key});

//   @override
//   Widget build(BuildContext context) {
//     bool showPassword = false;
//     void togglePasswordVisibility(bool? value) {
//       showPassword = value ?? false;
//     }

//     final _formKey = GlobalKey<FormState>();
//     final _emailController = TextEditingController();
//     final _passController = TextEditingController();

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.black,
//       body: SizedBox(
//         height: double.maxFinite,
//         child: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             Container(
//               foregroundDecoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.black,
//                     Colors.transparent,
//                     Colors.transparent,
//                     Colors.black,
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   stops: const [0.05, 0.4, 0.9, 1],
//                 ),
//               ),
//               child: Image.network(
//                 "https://cdn.polyspeak.ai/speakmaster/4747b3658f61e5da7f14fddc670a15df.webp",
//                 width: double.infinity,
//                 fit: BoxFit.contain,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 24.0),
//               child: Container(
//                 alignment: Alignment.bottomCenter,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.transparent,
//                       Colors.transparent,
//                       Colors.black,
//                       Colors.black,
//                       Colors.black,
//                     ],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Transform.translate(
//                   offset: const Offset(0, 12),
//                   child: LiquidGlass(
//                     settings: LiquidGlassSettings(
//                       blur: 4,
//                       glassColor: Colors.white.withAlpha(1),
//                       ambientStrength: 0.5,
//                       lightIntensity: 0.8,
//                     ),
//                     shape: LiquidRoundedRectangle(
//                       borderRadius: Radius.circular(16),
//                     ),
//                     child: SizedBox(
//                       height: 500,
//                       width: double.maxFinite,
//                       child: Container(
//                         alignment: Alignment.topCenter,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 26,
//                         ),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             spacing: 12,
//                             children: [
//                               Text(
//                                 "Bem vindo de volta",
//                                 style: AppTextStyles.titleLarge,
//                               ),
//                               Text(
//                                 "Faça login e acesse sua conta",
//                                 style: AppTextStyles.bodyLarge.copyWith(
//                                   color: tColorTertiary,
//                                 ),
//                               ),
//                               SizedBox(height: 8),
//                               TextInputWidget(
//                                 label: "Digite seu e-mail",
//                                 controller: _emailController,
//                               ),
//                               TextInputWidget(
//                                 label: "Digite sua senha",
//                                 controller: _passController,
//                                 isPassword: true,
//                               ),
//                               SizedBox(height: 8),
//                               ElevatedButton(
//                                 onPressed: () {},
//                                 child: Text("Entrar"),
//                               ),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(
//                                     "Não possui uma conta? ",
//                                     style: AppTextStyles.labelMedium.copyWith(
//                                       color: tColorTertiary,
//                                     ),
//                                   ),
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.pushNamed(context, '/register');
//                                     },
//                                     child: Text(
//                                       "Cadastrar",
//                                       style: AppTextStyles.labelMedium.copyWith(
//                                         color: colorTertiary,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               OutlinedButton(
//                                 onPressed: () {},
//                                 child: Text("Continuar com Google"),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class LoginViewMael extends StatefulWidget {
  const LoginViewMael({super.key});

  @override
  State<LoginViewMael> createState() => _LoginViewMaelState();
}

class _LoginViewMaelState extends State<LoginViewMael>
    with SingleTickerProviderStateMixin {
  bool showPassword = false;
  bool _isKeyboardVisible = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Uma única animação controller para melhor performance
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Inicia animação uma vez só
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _checkKeyboardVisibility(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isVisible = keyboardHeight > 0;

    // Só atualiza se realmente mudou para evitar rebuilds desnecessários
    if (isVisible != _isKeyboardVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isKeyboardVisible = isVisible;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check keyboard visibility
    _checkKeyboardVisibility(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.maxFinite,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black,
                    Colors.transparent,
                    (_isKeyboardVisible) ? Colors.black : Colors.transparent,
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.05, 0.4, _isKeyboardVisible ? 0.8 : 0.9, 1],
                ),
              ),
              child: Image.network(
                "https://cdn.polyspeak.ai/speakmaster/4747b3658f61e5da7f14fddc670a15df.webp",
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 50,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: 138,
                  height: 28,
                  child: SvgPicture.asset("assets/logo/logowatchers.svg"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border(
                        top: BorderSide(
                          color: Color(0xFF717171).withOpacity(0.83),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: SingleChildScrollView(
                          child: Container(
                            height: 500,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 26,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                spacing: 12,
                                children: [
                                  // Elementos com animação simples e unificada
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        spacing: 12,
                                        children: [
                                          Text(
                                            "Bem vindo de volta",
                                            style: AppTextStyles.titleLarge,
                                          ),
                                          Text(
                                            "Faça login e acesse sua conta",
                                            style: AppTextStyles.bodyLarge
                                                .copyWith(
                                                  color: tColorTertiary,
                                                ),
                                          ),
                                          SizedBox(height: 8),
                                          TextInputWidget(
                                            label: "Digite seu e-mail",
                                            controller: _emailController,
                                          ),
                                          TextInputWidget(
                                            label: "Digite sua senha",
                                            controller: _passController,
                                            isPassword: true,
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {},
                                            child: Text("Entrar"),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Não possui uma conta? ",
                                                style: AppTextStyles.labelMedium
                                                    .copyWith(
                                                      color: tColorTertiary,
                                                    ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/register',
                                                  );
                                                },
                                                child: Text(
                                                  "Cadastrar",
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                        color: colorTertiary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          OutlinedButton(
                                            onPressed: () {},
                                            child: Text("Continuar com Google"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
