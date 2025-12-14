import 'package:watchers/core/models/lists/list_author_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';

enum ListType {
  Favorites(0),
  Watchlist(1),
  Watched(2),
  Watching(3),
  Custom(4),
  Liked(5);

  final int value;
  const ListType(this.value);

  static ListType? fromInt(int value) {
    try {
      return ListType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }

  String get name {
    return switch (this) {
      ListType.Favorites => "Favorites",
      ListType.Watchlist => "Watchlist",
      ListType.Watched => "Watched",
      ListType.Watching => "Watching",
      ListType.Custom => "Custom",
      ListType.Liked => "Liked",
    };
  }
}

class ListModel {
  final String id;
  String name;
  final String createdAt;
  int likeCount;
  int commentCount;
  bool isPrivate;
  String? description;
  final ListAuthorModel author;
  final List<String> thumbnails;

  ListModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isPrivate,
    this.description,
    required this.author,
    required this.thumbnails,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isPrivate: json['private'] ?? false,
      description: json['description'] ?? '',
      author: ListAuthorModel.fromJson(json['author']),
      thumbnails: List<String>.from(json['thumbnails'] ?? []),
    );
  }
}
