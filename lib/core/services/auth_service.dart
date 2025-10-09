import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// Exceção personalizada para erros de autenticação
class AuthServiceException implements Exception {
  final String message;
  final String? code;

  AuthServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Serviço responsável por todas as operações de autenticação com Supabase
class AuthService {
  final SupabaseClient _supabase;
  final GoogleSignIn _googleSignIn;

  AuthService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client,
      _googleSignIn = GoogleSignIn.instance;

  /// Retorna o cliente Supabase
  SupabaseClient get client => _supabase;

  /// Retorna a sessão atual
  Session? get currentSession => _supabase.auth.currentSession;

  /// Retorna o usuário atual
  User? get currentUser => _supabase.auth.currentUser;

  /// Retorna o token de acesso atual
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  /// Retorna o refresh token atual
  String? get refreshToken => _supabase.auth.currentSession?.refreshToken;

  /// Retorna o UserModel do usuário autenticado atual
  UserModel? get currentUserModel {
    final user = currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }

  /// Stream que emite eventos de mudança de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Cadastra um novo usuário com email, senha e username
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Verifica se o username já existe
      final existingUser = await _supabase
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existingUser != null) {
        throw AuthServiceException(
          'Nome de usuário já está em uso',
          code: 'username_taken',
        );
      }

      // Cria o usuário
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw AuthServiceException(
          'Erro ao criar usuário',
          code: 'signup_failed',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro inesperado ao cadastrar: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Faz login com email e senha
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthServiceException(
          'Erro ao fazer login',
          code: 'signin_failed',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro inesperado ao fazer login: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Faz login com Google
  ///
  /// [iosClientId] - ID do cliente iOS (obrigatório para iOS)
  /// Throws [AuthServiceException] se houver erro
  Future<UserModel> signInWithGoogle({String? iosClientId}) async {
    try {
      const defaultIosClientId =
          '276021947227-63ngg60sc0au2na9d5jg8qkfn2kir54r.apps.googleusercontent.com';
      final clientId = iosClientId ?? defaultIosClientId;
      final scopes = ['email', 'profile'];

      await _googleSignIn.initialize(clientId: clientId);

      final googleUser = await _googleSignIn.authenticate();

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthServiceException(
          'Não foi possível obter o token do Google',
          code: 'no_id_token',
        );
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      if (response.user == null) {
        throw AuthServiceException(
          'Erro ao autenticar com Google',
          code: 'google_signin_failed',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro inesperado ao autenticar com Google: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Faz logout do usuário atual
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _googleSignIn.disconnect();
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro inesperado ao fazer logout: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Envia email de recuperação de senha
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro ao enviar email de recuperação: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Atualiza a senha do usuário
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro ao atualizar senha: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Atualiza o perfil do usuário
  ///
  /// Throws [AuthServiceException] se houver erro
  Future<UserModel> updateProfile({
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (metadata != null) data.addAll(metadata);

      final response = await _supabase.auth.updateUser(
        UserAttributes(data: data),
      );

      if (response.user == null) {
        throw AuthServiceException(
          'Erro ao atualizar perfil',
          code: 'update_failed',
        );
      }

      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AuthServiceException(e.message, code: e.statusCode);
    } catch (e) {
      throw AuthServiceException(
        'Erro ao atualizar perfil: ${e.toString()}',
        code: 'unknown_error',
      );
    }
  }

  /// Verifica se o usuário está autenticado
  bool get isAuthenticated => currentUser != null;

  /// Limpa dados de autenticação local (útil para debugging)
  Future<void> clearLocalAuth() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Ignora erros ao limpar
    }
  }
}
