class ListAuthorModel {
  final String id;
  final String username;
  final String? avatarUrl;

  ListAuthorModel({required this.id, required this.username, this.avatarUrl});

  factory ListAuthorModel.fromJson(Map<String, dynamic> json) =>
      ListAuthorModel(
        id: json["id"],
        username: json["username"],
        avatarUrl: json["avatar_url"],
      );
}
