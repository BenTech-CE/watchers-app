import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/global/search_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/theme/theme.dart';
import 'package:watchers/views/auth/login_view.dart';
import 'package:watchers/views/auth/register_view.dart';
import 'package:watchers/views/home/home_page.dart';
import 'package:watchers/views/intro/favorited_series.dart';
import 'package:watchers/views/intro/watched_series.dart';
import 'package:watchers/views/list/add_multiple_to_list_page.dart';
import 'package:watchers/views/list/add_single_to_list_page.dart';
import 'package:watchers/views/list/create_list_page.dart';
import 'package:watchers/views/list/list_details_page.dart';
import 'package:watchers/views/list/trending_lists.dart';
import 'package:watchers/views/main_page.dart';
import 'package:watchers/views/home/preview.dart';
import 'package:watchers/views/profile/diary_page.dart';
import 'package:watchers/views/profile/edit_profile_page.dart';
import 'package:watchers/views/profile/profile_lists_page.dart';
import 'package:watchers/views/profile/profile_page.dart';
import 'package:watchers/views/profile/profile_reviews_page.dart';
import 'package:watchers/views/profile/profile_watchlist_page.dart';
import 'package:watchers/views/review/review_add_page.dart';
import 'package:watchers/views/review/review_details_page.dart';
import 'package:watchers/views/review/trending_reviews.dart';
import 'package:watchers/views/series/episode_page.dart';
import 'package:watchers/views/series/genre_series.dart';
import 'package:watchers/views/series/recent_series.dart';
import 'package:watchers/views/series/best_series.dart';
import 'package:watchers/views/series/season_page.dart';
import 'package:watchers/views/series/series_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa dados de formatação de data para pt_BR
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // só funciona se não for web
  if (!kIsWeb) {
    const iosClientId =
        '276021947227-63ngg60sc0au2na9d5jg8qkfn2kir54r.apps.googleusercontent.com';
    const webClientId =
        '276021947227-h37r6nsse28g6qm2vcbcqga303k7r615.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
  }

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
        ChangeNotifierProvider(
          create: (_) => ListsProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider(authService: authService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewsProvider(authService: authService),
        ),
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
          '/series/recent': (context) => const RecentSeries(),
          '/series/best': (context) => const BestSeries(),
          '/series/detail': (context) => const SeriesPage(),
          '/series/season': (context) => const SeasonPage(),
          '/series/episode': (context) => const EpisodePage(),
          '/series/genre': (context) => const GenreSeries(),
          '/review/trending': (context) => const TrendingReviews(),
          '/list/trending': (context) => const TrendingLists(),
          '/list/detail': (context) => const ListDetailsPage(),
          '/list/addsingle': (context) => const AddSingleToListPage(),
          '/list/addmultiple': (context) => const AddMultipleToListPage(),
          '/list/create': (context) => const CreateListPage(),
          '/review/add': (context) => const ReviewAddPage(),
          '/review/detail': (context) => const ReviewDetailsPage(),
          '/profile/edit': (context) => const EditProfilePage(),
          '/profile/diary': (context) => const DiaryPage(),
          '/profile/watchlist': (context) => const ProfileWatchlistPage(),
          '/profile/reviews': (context) => const ProfileReviewsPage(),
          '/profile/lists': (context) => const ProfileListsPage(),
          '/profile': (context) => const ProfilePage(),
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

class _AuthWrapperState extends State<AuthWrapper>
    with SingleTickerProviderStateMixin {
  bool _isRefreshing = true;
  bool _isTransitioning = false;
  Widget? _nextPage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configura animação de fade
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Fade in ao iniciar, depois verifica sessão
    _animationController.forward().then((_) {
      _refreshSessionAndCheckAuth();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _transitionToPage(Widget page) async {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
      _nextPage = page;
    });

    // Fade out
    await _animationController.reverse();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshSessionAndCheckAuth() async {
    try {
      final currentSession = Supabase.instance.client.auth.currentSession;

      // Se há uma sessão, tenta fazer refresh
      if (currentSession != null) {
        await Supabase.instance.client.auth.refreshSession();
      }

      // Determina a página de destino
      final session = Supabase.instance.client.auth.currentSession;
      final targetPage = session != null ? const MainPage() : const LoginView();

      // Faz a transição com fade out
      if (mounted) {
        await _transitionToPage(targetPage);
      }
    } catch (error) {
      // Erro ao fazer refresh, provavelmente sessão expirada
      if (mounted) {
        await _transitionToPage(const LoginView());

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
    final screenWidth = MediaQuery.of(context).size.width;
    final logoWidth = screenWidth * 0.4;
    final logoHeight = logoWidth * 0.2;

    // Enquanto está fazendo refresh, mostra loading com logo animada
    if (_isRefreshing) {
      return Scaffold(
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              width: logoWidth,
              height: logoHeight,
              child: SvgPicture.asset("assets/logo/logowatchers.svg"),
            ),
          ),
        ),
      );
    }

    // Após o fade out, mostra a página de destino
    if (_nextPage != null) {
      return _nextPage!;
    }

    // Fallback: escuta mudanças de autenticação em tempo real
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final authState = snapshot.data;

        if (snapshot.hasError) {
          return const LoginView();
        }

        // Usa o estado inicial do refresh ou o novo estado do stream
        final session =
            authState?.session ?? Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const MainPage();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
