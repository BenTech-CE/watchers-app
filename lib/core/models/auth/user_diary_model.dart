class UserDiaryModel {
  int id;
  String? posterUrl;
  double? stars;
  bool? liked;
  String? lastInteraction;

  UserDiaryModel({
    required this.id,
    required this.posterUrl,
    required this.stars,
    required this.liked,
    required this.lastInteraction,
  });

  factory UserDiaryModel.fromJson(Map<String, dynamic> json) {
    return UserDiaryModel(
      id: json['id'],
      posterUrl: json['poster_url'],
      stars: json['stars'] != null ? (json['stars'] as num).toDouble() : null,
      liked: json['liked'],
      lastInteraction: json['last_interaction'],
    );
  }
}