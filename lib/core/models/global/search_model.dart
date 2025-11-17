import 'package:watchers/core/models/auth/profile_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';

class SearchModel {
  final List<SerieModel> series;
  final List<ProfileModel> users;
  final List<ListModel> lists;
  final List<ReviewModel> reviews;

  const SearchModel({
    required this.series,
    required this.users,
    required this.lists,
    required this.reviews,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      series:
          (json['series'] as List<dynamic>?)
              ?.map((e) => SerieModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      users:
          (json['profiles'] as List<dynamic>?)
              ?.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lists:
          (json['lists'] as List<dynamic>?)
              ?.map((e) => ListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
