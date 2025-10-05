# AuthProvider - Documentação

## 📁 Estrutura de Arquivos

```
lib/
├── core/
│   ├── models/
│   │   └── user_model.dart          # Modelo de dados do usuário
│   ├── services/
│   │   └── auth_service.dart        # Serviço de autenticação Supabase
│   └── providers/
│       └── auth_provider.dart       # Provider de estado de autenticação
├── views/
│   └── auth/
│       └── login_example_provider.dart  # Exemplos de uso
└── main.dart                         # Configuração do Provider
```

## 🚀 Setup Inicial

### 1. Instalar Dependências

Já adicionado ao `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.2
  supabase_flutter: ^2.10.2
  google_sign_in: ^7.2.0
```

Execute:
```bash
flutter pub get
```

### 2. Configurar no main.dart

O `main.dart` já está configurado com o `MultiProvider`:

```dart
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth_provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        // ...
      ),
    );
  }
}
```

## 📖 Como Usar

### 1. Fazer Login

```dart
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/auth_provider.dart';

// Dentro de um widget/método
Future<void> _handleLogin() async {
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.signIn(
    email: 'usuario@exemplo.com',
    password: 'senha123',
  );

  if (success) {
    // Login bem-sucedido
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    // Mostrar erro
    print(authProvider.errorMessage);
  }
}
```

### 2. Fazer Cadastro

```dart
Future<void> _handleRegister() async {
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.signUp(
    email: 'novo@exemplo.com',
    password: 'senha123',
    username: 'meu_usuario',
  );

  if (success) {
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authProvider.errorMessage ?? 'Erro')),
    );
  }
}
```

### 3. Login com Google

```dart
Future<void> _handleGoogleLogin() async {
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.signInWithGoogle();

  if (success) {
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

### 4. Fazer Logout

```dart
Future<void> _handleLogout() async {
  final authProvider = context.read<AuthProvider>();
  
  await authProvider.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}
```

### 5. Acessar Dados do Usuário

#### Usando Consumer (reconstrui quando muda)

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    final user = authProvider.user;
    
    if (user == null) {
      return Text('Não autenticado');
    }
    
    return Column(
      children: [
        Text('Olá, ${user.username}!'),
        Text('Email: ${user.email}'),
        Text('ID: ${user.id}'),
      ],
    );
  },
)
```

#### Usando context.watch (reconstrui quando muda)

```dart
@override
Widget build(BuildContext context) {
  final authProvider = context.watch<AuthProvider>();
  final user = authProvider.user;
  
  return Text(user?.username ?? 'Visitante');
}
```

#### Usando context.read (não reconstrui)

Use quando só precisa chamar métodos, sem reconstruir o widget:

```dart
void _onButtonPress() {
  final authProvider = context.read<AuthProvider>();
  authProvider.signOut();
}
```

### 6. Pegar o Token de Acesso

```dart
// Em qualquer lugar com acesso ao context
final authProvider = context.read<AuthProvider>();
final token = authProvider.accessToken;

if (token != null) {
  // Usar o token em chamadas de API
  final response = await http.get(
    Uri.parse('https://api.exemplo.com/dados'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );
}
```

### 7. Verificar se Está Autenticado

```dart
final authProvider = context.watch<AuthProvider>();

if (authProvider.isAuthenticated) {
  return HomeScreen();
} else {
  return LoginScreen();
}
```

### 8. Mostrar Loading

```dart
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isLoading) {
      return CircularProgressIndicator();
    }
    
    return ElevatedButton(
      onPressed: _handleLogin,
      child: Text('Entrar'),
    );
  },
)
```

### 9. Recuperar Senha

```dart
Future<void> _handlePasswordReset() async {
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.resetPassword('usuario@exemplo.com');
  
  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Email enviado!')),
    );
  }
}
```

### 10. Atualizar Perfil

```dart
Future<void> _updateProfile() async {
  final authProvider = context.read<AuthProvider>();
  
  final success = await authProvider.updateProfile(
    username: 'novo_nome_usuario',
    avatarUrl: 'https://exemplo.com/avatar.jpg',
  );
  
  if (success) {
    print('Perfil atualizado!');
  }
}
```

## 🎯 Propriedades Disponíveis

### AuthProvider

| Propriedade | Tipo | Descrição |
|------------|------|-----------|
| `status` | `AuthStatus` | Status atual (initial, authenticated, unauthenticated, loading) |
| `user` | `UserModel?` | Dados do usuário autenticado |
| `errorMessage` | `String?` | Última mensagem de erro |
| `isLoading` | `bool` | Se está processando uma operação |
| `isAuthenticated` | `bool` | Se há um usuário autenticado |
| `accessToken` | `String?` | Token de acesso JWT |
| `refreshToken` | `String?` | Token de refresh |

### UserModel

| Propriedade | Tipo | Descrição |
|------------|------|-----------|
| `id` | `String` | ID único do usuário |
| `email` | `String` | Email do usuário |
| `username` | `String?` | Nome de usuário |
| `avatarUrl` | `String?` | URL do avatar |
| `createdAt` | `DateTime` | Data de criação |
| `metadata` | `Map?` | Metadados adicionais |

## 🔧 Métodos Disponíveis

### AuthProvider

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `signUp()` | `Future<bool>` | Cadastra novo usuário |
| `signIn()` | `Future<bool>` | Faz login com email/senha |
| `signInWithGoogle()` | `Future<bool>` | Faz login com Google |
| `signOut()` | `Future<bool>` | Faz logout |
| `resetPassword()` | `Future<bool>` | Envia email de recuperação |
| `updatePassword()` | `Future<bool>` | Atualiza senha |
| `updateProfile()` | `Future<bool>` | Atualiza perfil |
| `refreshUser()` | `void` | Recarrega dados do usuário |
| `clearError()` | `void` | Limpa mensagem de erro |

## 🎨 Exemplos Práticos

Veja exemplos completos em:
- `lib/views/auth/login_example_provider.dart`

Exemplos incluem:
- ✅ Tela de Login com validação
- ✅ Tela de Cadastro
- ✅ Widget de perfil de usuário
- ✅ Exibição de token
- ✅ Tratamento de erros
- ✅ Loading states

## 🛡️ Boas Práticas

1. **Use `context.read` para chamar métodos** (não reconstrui o widget)
2. **Use `context.watch` ou `Consumer` para observar mudanças** (reconstrui quando muda)
3. **Sempre verifique `mounted` antes de usar `context` em async**:
   ```dart
   final success = await authProvider.signIn(...);
   if (success && mounted) {
     Navigator.push(...);
   }
   ```
4. **Trate erros adequadamente**:
   ```dart
   if (!success) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(authProvider.errorMessage ?? 'Erro')),
     );
   }
   ```
5. **Use `clearError()` para limpar erros antigos** antes de nova operação

## 🔐 Segurança

- ✅ Tokens são gerenciados automaticamente pelo Supabase
- ✅ Refresh automático de tokens
- ✅ Validação de username duplicado no cadastro
- ✅ Erros tratados com mensagens amigáveis
- ⚠️ **NUNCA** exponha credenciais ou tokens em logs de produção

## 📱 Exemplo de Fluxo Completo

```dart
// 1. Usuário faz login
final success = await authProvider.signIn(
  email: email,
  password: password,
);

// 2. Provider atualiza automaticamente o estado
// - status: authenticated
// - user: UserModel com dados do usuário
// - accessToken: token JWT válido

// 3. Widgets que observam o provider são reconstruídos

// 4. Em outra tela, você pode acessar:
final token = context.read<AuthProvider>().accessToken;
final userName = context.watch<AuthProvider>().user?.username;

// 5. Ao fazer logout:
await authProvider.signOut();
// - status: unauthenticated
// - user: null
// - tokens: null
```

## 🐛 Troubleshooting

### Provider não encontrado
```dart
// ❌ Errado
context.read<AuthProvider>() // fora da árvore de widgets

// ✅ Correto
// Certifique-se que está dentro de um widget filho do MultiProvider
```

### Widget não atualiza
```dart
// ❌ Errado
final authProvider = context.read<AuthProvider>();

// ✅ Correto para observar mudanças
final authProvider = context.watch<AuthProvider>();
// ou
Consumer<AuthProvider>(
  builder: (context, authProvider, child) { ... }
)
```

### Erro "Bad state: No element"
Certifique-se que o Supabase foi inicializado antes de criar o AuthProvider:
```dart
await Supabase.initialize(...);
runApp(MyApp()); // que cria o AuthProvider
```

## 📚 Recursos Adicionais

- [Provider Documentation](https://pub.dev/packages/provider)
- [Supabase Flutter Documentation](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Google Sign-In Documentation](https://pub.dev/packages/google_sign_in)
