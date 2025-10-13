/// Modelo de usuário que representa os dados do usuário autenticado
class UserModel {
  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  UserModel({
    required this.id,
    required this.email,
    this.username,
    this.avatarUrl,
    required this.createdAt,
    this.metadata,
  });

  /// Cria um UserModel a partir de um User do Supabase
  factory UserModel.fromSupabaseUser(dynamic user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['username'] as String?,
      avatarUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      metadata: user.userMetadata as Map<String, dynamic>?,
    );
  }

  /// Cria uma cópia do UserModel com campos atualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Converte o UserModel para Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, username: $username)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
