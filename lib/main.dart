import 'package:flutter/material.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/theme/theme.dart';
import 'package:watchers/views/auth/register_view_jg.dart';
import 'package:watchers/views/auth/login_view_mael.dart';

void main() {
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
    return LoginViewJg();
  }
}
