import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/theme/theme.dart';
import 'package:watchers/views/auth/register_view_jg.dart';
import 'package:watchers/views/auth/login_view_mael.dart';
import 'package:watchers/views/auth/supabase_test.dart';

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
    return MaterialApp(
      title: 'Watchers',
      theme: AppTheme.theme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginViewMael();
  }
}
