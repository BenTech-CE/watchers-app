class ReviewModel {
  final int? id;
  final int? seasonNumber; // Novo campo do JSON
  final int? episodeNumber; // Novo campo do JSON
  final double? stars;
  final bool liked;
  final String? content; // Agora pode ser nulo
  final ReviewSeries series;
  final ReviewAuthor author;

  ReviewModel({
    required this.id,
    this.seasonNumber,
    this.episodeNumber,
    this.stars,
    required this.liked,
    this.content,
    required this.series,
    required this.author,
  });

  /// Getter calculado para manter a compatibilidade com sua lógica antiga de "type"
  String get type {
    if (episodeNumber != null) return 'episode';
    if (seasonNumber != null) return 'season';
    return 'series';
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json["id"] as int,

      // Mapeando os novos campos
      seasonNumber: json["season_number"] as int?,
      episodeNumber: json["episode_number"] as int?,

      // Tratamento seguro para números (int ou double)
      stars: json["stars"] != null ? (json["stars"] as num).toDouble() : null,

      // Bool seguro (se vier null, assume false)
      liked: json["liked"] as bool? ?? false,

      // Content aceita null agora
      content: json["content"] as String?,

      // ATENÇÃO: Seu SerieModel deve estar preparado para receber apenas
      // {id, name, poster_url}. Se o SerieModel exigir outros campos, vai dar erro.
      series: ReviewSeries.fromJson(json["series"]),

      author: ReviewAuthor.fromJson(json["author"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) "id": id,
      "season_number": seasonNumber,
      "episode_number": episodeNumber,
      "stars": stars,
      "liked": liked,
      "content": content,
    };
  }
}

class ReviewSeries {
  final int id;
  final String name;
  final String? posterUrl;

  ReviewSeries({required this.id, required this.name, this.posterUrl});

  factory ReviewSeries.fromJson(Map<String, dynamic> json) {
    return ReviewSeries(
      id: json["id"] as int,
      name: json["name"] as String,
      posterUrl: json["poster_url"] as String?,
    );
  }
}

class ReviewAuthor {
  final String id;
  final String username;
  final String? avatarUrl;

  ReviewAuthor({required this.id, required this.username, this.avatarUrl});

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) => ReviewAuthor(
    id: json["id"],
    username: json["username"],
    avatarUrl: json["avatar_url"],
  );
}
