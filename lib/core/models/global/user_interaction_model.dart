class UserInteractionData {
  bool isWatched;
  bool inWatchlist;
  int? reviewId;
  double? stars;
  String? reviewText;
  bool isLiked;

  UserInteractionData({
    required this.isWatched,
    required this.inWatchlist,
    this.reviewId,
    this.stars,
    this.reviewText,
    required this.isLiked,
  });

  factory UserInteractionData.fromJson(Map<String, dynamic> json) {
    return UserInteractionData(
      isWatched: json['is_watched'] as bool,
      inWatchlist: json['in_watchlist'] as bool,
      reviewId: json['review_id'] as int?,
      stars: (json['stars'] as num?)?.toDouble(),
      reviewText: json['review_text'] as String?,
      isLiked: json['is_liked'] as bool,
    );
  }

  factory UserInteractionData.empty() {
    return UserInteractionData(
      isWatched: false,
      inWatchlist: false,
      reviewId: null,
      stars: null,
      reviewText: null,
      isLiked: false,
    );
  }
}