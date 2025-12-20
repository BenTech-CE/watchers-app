class ProfileModel {
  final String id;
  final String username;
  final String? fullName;
  final String avatarUrl;
  bool isFollowing;

  ProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.avatarUrl,
    this.isFollowing = false,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'] ?? '',
      isFollowing: json['is_following'] ?? false,
    );
  }
}
