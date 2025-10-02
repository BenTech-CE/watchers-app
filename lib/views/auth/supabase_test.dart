import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SupabaseTestView extends StatefulWidget {
  const SupabaseTestView({super.key});

  @override
  State<SupabaseTestView> createState() => _SupabaseTestViewState();
}

class _SupabaseTestViewState extends State<SupabaseTestView> {
  bool _isCadastro = false;

  final supabase = Supabase.instance.client;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  Session? _session;
  User? _user;

  void _cadastrar() async {
    try {
      if (_emailController.text.isEmpty ||
          _passController.text.isEmpty ||
          _usernameController.text.isEmpty) {
        return;
      }

      final existingData = await supabase
          .from('profiles')
          .select("username")
          .eq('username', _usernameController.text)
          .maybeSingle();

      if (existingData != null) {
        throw AuthException('Usuário já registrado com esse nome de usuário.');
      }

      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text,
        password: _passController.text,
        data: {"username": _usernameController.text},
      );

      getUserInfo();
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _login() async {
    try {
      if (_emailController.text.isEmpty || _passController.text.isEmpty) return;

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      getUserInfo();
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _sairConta() async {
    try {
      await supabase.auth.signOut();

      setState(() {
        _session = null;
        _user = null;
      });
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _autenticarComGoogle() async {
    try {
      // const iosClientId = '276021947227-63ngg60sc0au2na9d5jg8qkfn2kir54r.apps.googleusercontent.com';
      final scopes = ['email', 'profile'];

      final googleSignIn = GoogleSignIn.instance;

      // await googleSignIn.initialize(
      //   clientId: iosClientId,
      // );

      final googleUser = await googleSignIn.authenticate();

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('No ID Token found.');
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      getUserInfo();
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void getUserInfo() async {
    try {
      setState(() {
        _session = supabase.auth.currentSession;
        _user = supabase.auth.currentUser;
      });
    } catch (error) {
      final snackBar = SnackBar(content: Text(error.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Integração com Supabase")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            Row(
              children: [
                Text("Formulário de Cadastro?"),
                Checkbox(
                  value: _isCadastro,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isCadastro = newValue!;
                    });
                  },
                ),
              ],
            ),
            _isCadastro
                ? TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(hint: Text("Nome de Usuário")),
                  )
                : Container(),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hint: Text("E-mail")),
            ),
            TextField(
              controller: _passController,
              decoration: InputDecoration(hint: Text("Senha")),
            ),
            FilledButton(
              onPressed: _isCadastro ? _cadastrar : _login,
              child: Text(_isCadastro ? "Cadastrar" : "Entrar"),
            ),
            FilledButton(
              onPressed: _autenticarComGoogle,
              child: Text("Google"),
            ),
            _session != null
                ? FilledButton(
                    onPressed: _sairConta,
                    child: Text("Sair da Conta"),
                  )
                : Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "AccessToken: ${_session?.accessToken.substring(0, 15)}...",
                ),
                _session != null
                    ? IconButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _session!.accessToken),
                          );
                        },
                        icon: Icon(Icons.copy),
                        iconSize: 24,
                      )
                    : Container(),
              ],
            ),
            Text("User: ${_user?.userMetadata?["username"]} (${_user?.id})"),
          ],
        ),
      ),
    );
  }
}
