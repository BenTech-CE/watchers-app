import 'package:watchers/core/models/lists/list_model.dart';

class FullListModel {
  String id;
  ListModel listData;
  ListAdditionalData additionalData;

  FullListModel({
    required this.id,
    required this.listData,
    required this.additionalData,
  });

  factory FullListModel.fromJson(Map<String, dynamic> json) {
    return FullListModel(
      id: json['id'],
      listData: ListModel.fromJson(json['list_data']),
      additionalData: ListAdditionalData.fromJson(json['additional_data']),
    );
  }
}

class ListAdditionalData {
  String createdAt;
  List<ListAdditionalDataSeries> series;
  List<ListLikedUser> likedBy;

  ListAdditionalData({
    required this.createdAt,
    required this.series,
    required this.likedBy,
  });

  factory ListAdditionalData.fromJson(Map<String, dynamic> json) {
    var seriesFromJson = json['series'] as List;
    List<ListAdditionalDataSeries> seriesList = seriesFromJson.map((i) => ListAdditionalDataSeries.fromJson(i)).toList();

    var likedByFromJson = json['liked_by'] as List;
    List<ListLikedUser> likedByList = likedByFromJson.map((i) => ListLikedUser.fromJson(i)).toList();

    return ListAdditionalData(
      createdAt: json['created_at'],
      series: seriesList,
      likedBy: likedByList,
    );
  }
}

class ListAdditionalDataSeries {
  int id;
  String? posterUrl;
  String? backgroundUrl;

  ListAdditionalDataSeries({
    required this.id,
    this.posterUrl,
    this.backgroundUrl,
  });

  factory ListAdditionalDataSeries.fromJson(Map<String, dynamic> json) {
    return ListAdditionalDataSeries(
      id: json['id'],
      posterUrl: json['poster_url'],
      backgroundUrl: json['background_url'],
    );
  }
}

class ListLikedUser {
  String id;
  String? avatarUrl;

  ListLikedUser({
    required this.id,
    this.avatarUrl,
  });

  factory ListLikedUser.fromJson(Map<String, dynamic> json) {
    return ListLikedUser(
      id: json['id'],
      avatarUrl: json['avatar_url'],
    );
  }
}