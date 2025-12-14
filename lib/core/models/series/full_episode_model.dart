import 'package:watchers/core/models/global/star_distribution_model.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';

class FullEpisodeModel {
  UserInteractionData? userData;
  List<StarDistributionModel>? starDistribution;
  List<ReviewModel>? reviews;

  FullEpisodeModel({
    this.userData,
    this.starDistribution,
    this.reviews,
  });

  factory FullEpisodeModel.fromJson(Map<String, dynamic> json) {
    return FullEpisodeModel(
      userData: json['userData'] == null
          ? null
          : UserInteractionData.fromJson(
              json['userData'] as Map<String, dynamic>),
      starDistribution: (json['starDistribution'] as List<dynamic>?)
          ?.map((e) =>
              StarDistributionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}