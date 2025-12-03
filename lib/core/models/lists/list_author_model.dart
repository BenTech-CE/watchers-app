class ListAuthorModel {
  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  ListAuthorModel({required this.id, required this.username, this.fullName, this.avatarUrl});

  factory ListAuthorModel.fromJson(Map<String, dynamic> json) =>
      ListAuthorModel(
        id: json["id"],
        username: json["username"],
        fullName: json["full_name"],
        avatarUrl: json["avatar_url"],
      );
}
