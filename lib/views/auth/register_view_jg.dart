import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/input.dart';

/*
TODO:
1. Arrumar o Padding
2. Adicionar botões de login com Google, Facebook e Apple
3. Adicionar botão de "Já possui uma conta? Faça login"
4. Adicionar validação de formulário
5. Adicionar funcionalidade de mostrar/ocultar senha
6. Melhorar a responsividade para diferentes tamanhos de tela
7. Consertar o TextField horrível (aplicar o LiquidGlass nele)
8. Aplicar o LiquidGlass no Container do formulário
9. Adicionar animações sutis para melhorar a experiência do usuário
10. Testar em diferentes dispositivos e corrigir bugs
*/

class LoginViewJg extends StatelessWidget {
  const LoginViewJg({super.key});

  @override
  Widget build(BuildContext context) {
    bool showPassword = false;
    void togglePasswordVisibility(bool? value) {
      showPassword = value ?? false;
    }

    final _usernameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passController = TextEditingController();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
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
                    child: Image.network(
                      "https://cdn.polyspeak.ai/speakmaster/4747b3658f61e5da7f14fddc670a15df.webp",
                      width: double.infinity,
                      fit: BoxFit.contain,
                      opacity: const AlwaysStoppedAnimation(0.75),
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 150,),
                        Text("Seja bem-vindo ao", style: Theme.of(context).textTheme.displayMedium,),
                        Text("Watchers", style: AppTextStyles.titleLargeBright,),
                        Text("Cadastre-se e comece a produzir suas críticas!", style: Theme.of(context).textTheme.displaySmall,)
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                    alignment: Alignment.center,
                    child: LiquidGlass(
                      settings: LiquidGlassSettings(
              
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          spacing: 16,
                          children: [
                            Text("Para cadastrar-se, preencha os campos abaixo:", style: AppTextStyles.bodyLargeBright,),
                            TextInputWidget(label: "Nome de Usuário", hint: "Digite um nome de usuário bem legal", controller: _usernameController,),
                            TextInputWidget(label: "E-mail", hint: "Digite seu melhor e-mail", controller: _emailController,),
                            TextInputWidget(label: "Senha", hint: "Digite uma senha muito forte", controller: _passController,),
                            Row(
                              children: [
                                Text("Mostrar senha", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),),
                                Checkbox(value: showPassword, onChanged: (value) => togglePasswordVisibility(value)),
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                      shape: LiquidRoundedRectangle(
                        borderRadius: Radius.circular(16),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}