import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';

class HomeModel {
  final List<SerieModel> trending;
  final List<SerieModel> topRated;
  final List<SerieModel> recent;

  final List<ReviewModel> reviews;
  final List<ListModel> lists;

  HomeModel({
    required this.trending,
    required this.topRated,
    required this.recent,
    required this.reviews,
    required this.lists,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      trending: (json['trending'] as List)
          .map((item) => SerieModel.fromJson(item))
          .toList(),
      topRated: (json['top_rated'] as List)
          .map((item) => SerieModel.fromJson(item))
          .toList(),
      recent: (json['recent'] as List)
          .map((item) => SerieModel.fromJson(item))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((item) => ReviewModel.fromJson(item))
          .toList(),
      lists: (json['lists'] as List)
          .map((item) => ListModel.fromJson(item))
          .toList(),
    );
  }
}