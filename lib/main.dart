import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/theme/theme.dart';
import 'package:watchers/views/auth/login_view.dart';
import 'package:watchers/views/auth/register_view.dart';
import 'package:watchers/views/home_page.dart';
import 'package:watchers/views/intro/favorited_series.dart';
import 'package:watchers/views/intro/watched_series.dart';
import 'package:watchers/views/main_page.dart';
import 'package:watchers/views/preview.dart';

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

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => SeriesProvider(authService: authService),
        ),
        ChangeNotifierProvider(create: (_) => ListsProvider(authService: authService))
      ],
      child: MaterialApp(
        title: 'Watchers',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterViewMael(),
          '/home': (context) => const MainPage(),
          '/onboarding/watched': (context) => const WatchedSeries(),
          '/onboarding/favorited': (context) => const FavoritedSeries(),
        },
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que gerencia o refresh da sessão e decide qual tela mostrar
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _refreshSessionAndCheckAuth();
  }

  Future<void> _refreshSessionAndCheckAuth() async {
    try {
      final currentSession = Supabase.instance.client.auth.currentSession;
      
      // Se há uma sessão, tenta fazer refresh
      if (currentSession != null) {
        await Supabase.instance.client.auth.refreshSession();
      }
      
      // Finaliza o loading após refresh (ou se não havia sessão)
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    } catch (error) {
      // Erro ao fazer refresh, provavelmente sessão expirada
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sessão expirada: ${error.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto está fazendo refresh, mostra loading
    if (_isRefreshing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Carregando...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Após refresh, escuta mudanças de autenticação
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final authState = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Erro de autenticação'),
            ),
          );
        }

        // Usa o estado inicial do refresh ou o novo estado do stream
        final session = authState?.session ?? Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const MainPage();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
