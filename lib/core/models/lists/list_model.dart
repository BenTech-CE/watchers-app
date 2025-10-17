enum ListType {
  Favorites(0),
  Watchlist(1),
  Watched(2),
  Watching(3);

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
    };
  }
}

class ListModel {
  final String id;
  final ListType type;
  final String name;
  final String createdAt;
  final int seriesCount;

  const ListModel({
    required this.id,
    required this.type,
    required this.name,
    required this.createdAt,
    required this.seriesCount,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'].toString(),
      type: ListType.fromInt(json['type']) ?? ListType.Watchlist,
      name: json['name'] ?? '',
      createdAt: json['created_at'] ?? '',
      seriesCount: json['series_count'] ?? 0,
    );
  }
}
