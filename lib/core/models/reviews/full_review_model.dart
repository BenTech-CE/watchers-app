import 'package:watchers/core/models/global/comment_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';

class FullReviewModel {
  int id;
  ReviewModel reviewData;
  ReviewAdditionalData additionalData;

  FullReviewModel({
    required this.id,
    required this.reviewData,
    required this.additionalData,
  });

  factory FullReviewModel.fromJson(Map<String, dynamic> json) {
    return FullReviewModel(
      id: json['id'],
      reviewData: ReviewModel.fromJson(json['review_data']),
      additionalData: ReviewAdditionalData.fromJson(json['additional_data']),
    );
  }
}

class ReviewAdditionalData {
  String backgroundUrl;
  int likeCount;
  int commentCount;
  String createdAt;
  String updatedAt;
  bool userLiked;
  List<ReviewLikedUser> likedBy;
  List<CommentModel> comments;

  ReviewAdditionalData({
    required this.backgroundUrl,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
    required this.commentCount,
    this.userLiked = false,
    this.likedBy = const [],
    this.comments = const [],
  });

  factory ReviewAdditionalData.fromJson(Map<String, dynamic> json) {
    var likedByFromJson = json['liked_by'] as List;
    List<ReviewLikedUser> likedByList = likedByFromJson.map((i) => ReviewLikedUser.fromJson(i)).toList();

    var commentsFromJson = json['comments'] as List;
    List<CommentModel> commentsList = commentsFromJson.map((i) => CommentModel.fromJson(i)).toList();

    return ReviewAdditionalData(
      backgroundUrl: json['background_url'],
      likeCount: json['like_count'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userLiked: json['user_liked'] ?? false,
      commentCount: json['comment_count'],
      likedBy: likedByList,
      comments: commentsList
    );
  }
}

class ReviewLikedUser {
  String id;
  String? avatarUrl;

  ReviewLikedUser({
    required this.id,
    this.avatarUrl,
  });

  factory ReviewLikedUser.fromJson(Map<String, dynamic> json) {
    return ReviewLikedUser(
      id: json['id'],
      avatarUrl: json['avatar_url'],
    );
  }
}