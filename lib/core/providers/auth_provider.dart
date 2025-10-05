import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Estados de autenticação
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// Provider de autenticação que gerencia o estado da autenticação
/// e expõe métodos para login, cadastro e logout
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService() {
    _initialize();
  }

  // Getters públicos
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get accessToken => _authService.accessToken;
  String? get refreshToken => _authService.refreshToken;

  /// Inicializa o provider e escuta mudanças de autenticação
  void _initialize() {
    // Verifica se já existe uma sessão
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = UserModel.fromSupabaseUser(currentUser);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }

    // Escuta mudanças de autenticação
    _authService.authStateChanges.listen((AuthState state) {
      final event = state.event;
      
      if (event == AuthChangeEvent.signedIn) {
        if (state.session?.user != null) {
          _user = UserModel.fromSupabaseUser(state.session!.user);
          _status = AuthStatus.authenticated;
          _errorMessage = null;
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        if (state.session?.user != null) {
          _user = UserModel.fromSupabaseUser(state.session!.user);
          notifyListeners();
        }
      } else if (event == AuthChangeEvent.userUpdated) {
        if (state.session?.user != null) {
          _user = UserModel.fromSupabaseUser(state.session!.user);
          notifyListeners();
        }
      }
    });
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define a mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  /// Faz cadastro de novo usuário
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signUp(
        email: email,
        password: password,
        username: username,
      );

      _user = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao cadastrar');
      return false;
    }
  }

  /// Faz login com email e senha
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signIn(
        email: email,
        password: password,
      );

      _user = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao fazer login');
      return false;
    }
  }

  /// Faz login com Google
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> signInWithGoogle({String? iosClientId}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _authService.signInWithGoogle(
        iosClientId: iosClientId,
      );

      _user = user;
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao autenticar com Google');
      return false;
    }
  }

  /// Faz logout do usuário
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.signOut();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro inesperado ao fazer logout');
      return false;
    }
  }

  /// Envia email de recuperação de senha
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro ao enviar email de recuperação');
      return false;
    }
  }

  /// Atualiza a senha do usuário
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> updatePassword(String newPassword) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      await _authService.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro ao atualizar senha');
      return false;
    }
  }

  /// Atualiza o perfil do usuário
  ///
  /// Retorna true se bem-sucedido, false caso contrário
  Future<bool> updateProfile({
    String? username,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final updatedUser = await _authService.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
        metadata: metadata,
      );

      _user = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthServiceException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Erro ao atualizar perfil');
      return false;
    }
  }

  /// Recarrega os dados do usuário atual
  void refreshUser() {
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      _user = UserModel.fromSupabaseUser(currentUser);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Limpa recursos se necessário
    super.dispose();
  }
}
