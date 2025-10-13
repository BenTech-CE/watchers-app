import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Bem-vindo à Home Page!'),
            const Text('Você está logado.'),
            const Text('Informações da sessão atual:'),
            Text('${authInfo.user?.username}'),
            Text('Status de Autenticação: ${authInfo.status}'),
            Text('Id: ${authInfo.user?.id}'),
            Text('E-mail: ${authInfo.user?.email}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "AccessToken: ${authInfo.accessToken?.substring(0, 15)}...",
                ),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: authInfo.accessToken!),
                    );
                  },
                  icon: Icon(Icons.copy),
                  iconSize: 24,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                authInfo.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
