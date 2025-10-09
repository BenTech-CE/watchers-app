import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth_provider.dart';
import 'package:watchers/core/theme/theme.dart';
import 'package:watchers/views/auth/login_view.dart';
import 'package:watchers/views/auth/register_view.dart';
import 'package:watchers/views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const iosClientId =
      '276021947227-63ngg60sc0au2na9d5jg8qkfn2kir54r.apps.googleusercontent.com';
  const webClientId =
      '276021947227-h37r6nsse28g6qm2vcbcqga303k7r615.apps.googleusercontent.com';

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  await Supabase.initialize(
    url: 'https://rifsqeyjlvjmzhgmckqu.supabase.co',
    anonKey: 'sb_publishable_fZNUvwbb3NgXkifW0fJ9Aw_QdSHQine',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    return session != null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Watchers',
        theme: AppTheme.theme,
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterViewMael(),
          '/home': (context) => const HomePage(),
        },
        home: FutureBuilder<bool>(
          future: checkSession(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Se estiver logado, vai pra Home; senão, pra Login
            if (snapshot.data == true) {
              return const HomePage();
            } else {
              return const LoginView();
            }
          },
        ),
      ),
    );
  }
}
