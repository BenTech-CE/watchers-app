class SerieModel {
  final String id;
  final double popularity;
  final String originalName;
  final String name;
  final String backgroundUrl;
  final String posterUrl;
  final String overview;

  const SerieModel({
    required this.id,
    required this.popularity,
    required this.originalName,
    required this.name,
    required this.backgroundUrl,
    required this.posterUrl,
    required this.overview,
  });

  factory SerieModel.fromJson(Map<String, dynamic> json) {
    return SerieModel(
      id: json['id'].toString(),
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      originalName: json['original_name'] ?? '',
      name: json['name'] ?? '',
      backgroundUrl: json['background_url'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      overview: json['overview'] ?? '',
    );
  }
}
