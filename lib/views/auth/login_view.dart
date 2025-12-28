import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/validators/validators.dart';
import 'package:watchers/widgets/input.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
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

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoading) return;

    final success = await authProvider.signIn(
      email: _emailController.text,
      password: _passController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erro ao fazer login'),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isLoading) return;

    final success = await authProvider.signInWithGoogle();

    if (success && mounted && authProvider.user != null) {
      // se a conta foi criada há menos de 3 minutos, é um novo usuário (POG)
      if (authProvider.user!.createdAt
              .difference(DateTime.now())
              .inMinutes
              .abs() <
          3) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Erro ao fazer login com Google',
          ),
        ),
      );
    }
  }

  /*Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passController.text,
      username: _usernameController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Erro ao cadastrar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // Check keyboard visibility
    _checkKeyboardVisibility(context);

    final authProvider = context.watch<AuthProvider>();

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
              child: Image.asset(
                "images/bgwatchers.webp",
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
                                            validator:
                                                FormValidators.validateEmail,
                                          ),
                                          TextInputWidget(
                                            label: "Digite sua senha",
                                            controller: _passController,
                                            isPassword: true,
                                            validator: FormValidators.notNull,
                                          ),
                                          SizedBox(height: 8),
                                          SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  _handleLogin();
                                                }
                                              },
                                              child: authProvider.isLoading
                                                  ? SizedBox.square(
                                                      dimension: 18,
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                    )
                                                  : Text("Entrar"),
                                            ),
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
                                                  Navigator.pushReplacementNamed(
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
                                          if (!kIsWeb)
                                            SizedBox(
                                              height: 40,
                                              child: OutlinedButton(
                                                onPressed: _handleGoogleSignIn,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 18,
                                                      width: 18,
                                                      child: Image.asset(
                                                        "assets/images/google.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Continuar com o Google",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
