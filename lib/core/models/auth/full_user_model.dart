import 'package:watchers/core/models/global/star_distribution_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';

class FullUserModel {
  final String id;
  String username;
  String? fullName;
  String? avatarUrl;
  String? bio;
  final String createdAt;
  int followingCount;
  int followerCount;
  bool privateWatchlist;
  List<ListModel> lists;
  List<SerieModel> favorites;
  List<ReviewModel> reviews;
  List<SerieModel> watchlist;
  List<StarDistributionModel> starDistribution;

  FullUserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
    this.bio,
    required this.createdAt,
    required this.followingCount,
    required this.followerCount,
    required this.privateWatchlist,
    required this.lists,
    required this.favorites,
    required this.reviews,
    required this.watchlist,
    required this.starDistribution,
  });

  factory FullUserModel.fromJson(Map<String, dynamic> json) {
    return FullUserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      createdAt: json['created_at'] ?? '',
      followingCount: json['following_count'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      privateWatchlist: json['private_watchlist'] ?? false,
      lists: (json['lists'] as List<dynamic>?)
              ?.map((e) => ListModel.fromJson(e))
              .toList() ??
          [],
      favorites: (json['favorites'] as List<dynamic>?)
              ?.map((e) => SerieModel.fromJson(e))
              .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
      watchlist: (json['watchlist'] as List<dynamic>?)
              ?.map((e) => SerieModel.fromJson(e))
              .toList() ??
          [],
      starDistribution: (json['star_distribution'] as List<dynamic>?)
              ?.map((e) => StarDistributionModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}