import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: SizedBox(
          width: 138,
          height: 28,
          child: SvgPicture.asset("assets/logo/logowatchers.svg"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Usuário atual:'),
            Text('Username: ${authInfo.user?.username}'),
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
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/onboarding/watched');
              },
              child: const Text('Ir para Intro'),
            ),
          ],
        ),
      ),
    );
  }
}
