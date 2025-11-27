import 'package:watchers/core/models/global/star_distribution_model.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';

class FullSeasonModel {
  String? airDate;
  List<SeasonEpisode> episodes;
  String? name;
  List<Network> networks;
  String? overview;
  int id;
  String? posterPath;
  int? seasonNumber;
  double? voteAverage;
  UserInteractionData? userData;
  List<StarDistributionModel>? starDistribution;
  List<ReviewModel>? reviews;

  FullSeasonModel({
    this.airDate,
    required this.episodes,
    this.name,
    required this.networks,
    this.overview,
    required this.id,
    this.posterPath,
    this.seasonNumber,
    this.voteAverage,
    this.userData,
    this.starDistribution,
    this.reviews,
  });

  factory FullSeasonModel.fromJson(Map<String, dynamic> json) {
    return FullSeasonModel(
      airDate: json['air_date'],
      episodes: json['episodes'] != null
          ? List<SeasonEpisode>.from(
              json['episodes'].map((e) => SeasonEpisode.fromJson(e)))
          : [],
      networks: json['networks'] != null
          ? List<Network>.from(json['networks'].map((e) => Network.fromJson(e)))
          : [],
      overview: json['overview'],
      id: json['id'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'],
      voteAverage: json['vote_average']?.toDouble(),
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

class SeasonImages {
  List<ImageFile> posters;

  SeasonImages({required this.posters});

  factory SeasonImages.fromJson(Map<String, dynamic> json) {
    return SeasonImages(
      posters: json['posters'] != null
          ? List<ImageFile>.from(
              json['posters'].map((e) => ImageFile.fromJson(e)))
          : [],
    );
  }
}

class SeasonEpisode {
  String? airDate;
  int? episodeNumber;
  String? episodeType;
  int id;
  String? name;
  String? overview;
  String? productionCode;
  int? runtime;
  int? seasonNumber;
  String? stillPath;
  double? voteAverage;
  int? voteCount;
  List<Crew> crew;
  List<Cast> guestStars;

  SeasonEpisode({
    this.airDate,
    this.episodeNumber,
    this.episodeType,
    required this.id,
    this.name,
    this.overview,
    this.productionCode,
    this.runtime,
    this.seasonNumber,
    this.stillPath,
    this.voteAverage,
    this.voteCount,
    required this.crew,
    required this.guestStars,
  });

  factory SeasonEpisode.fromJson(Map<String, dynamic> json) {
    return SeasonEpisode(
      airDate: json['air_date'],
      episodeNumber: json['episode_number'],
      episodeType: json['episode_type'],
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      productionCode: json['production_code'],
      runtime: json['runtime'],
      seasonNumber: json['season_number'],
      stillPath: json['still_path'],
      voteAverage: json['vote_average']?.toDouble(),
      voteCount: json['vote_count'],
      crew: json['crew'] != null
          ? List<Crew>.from(json['crew'].map((e) => Crew.fromJson(e)))
          : [],
      guestStars: json['guest_stars'] != null
          ? List<Cast>.from(json['guest_stars'].map((e) => Cast.fromJson(e)))
          : [],
    );
  }
}