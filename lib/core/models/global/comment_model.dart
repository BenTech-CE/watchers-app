class CommentModel {
  int id;
  String content;
  String createdAt;
  CommentAuthor author;

  CommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      createdAt: json['created_at'],
      author: CommentAuthor.fromJson(json['author']),
    );
  }
}

class CommentAuthor {
  String id;
  String username;
  String? fullName;
  String? avatarUrl;

  CommentAuthor({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  factory CommentAuthor.fromJson(Map<String, dynamic> json) {
    return CommentAuthor(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
    );
  }
}