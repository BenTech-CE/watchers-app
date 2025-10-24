import 'package:watchers/core/models/series/serie_model.dart';

class ReviewModel {
    final String id;
    final String type; // "season", "episode" ou "series"
    final String? reviewed;
    final double stars;
    final bool liked;
    final String content;
    final SerieModel series; // <--- ALTERADO AQUI
    final ReviewAuthor author;

    ReviewModel({
        required this.id,
        required this.type,
        this.reviewed,
        required this.stars,
        required this.liked,
        required this.content,
        required this.series, // O tipo aqui agora é SerieModel
        required this.author,
    });

    /// Cria uma instância de [ReviewModel] a partir de um mapa JSON.
    factory ReviewModel.fromJson(Map<String, dynamic> json) {
        return ReviewModel(
            id: json["id"],
            type: json["type"],
            // A chave 'reviewed' pode ser nula ou inexistente no JSON
            reviewed: json["reviewed"], 
            // Converte 'num' (int ou double) para double com segurança
            stars: (json["stars"] as num).toDouble(), 
            liked: json["liked"],
            content: json["content"],
            // Chama o construtor fromJson da classe aninhada
            series: SerieModel.fromJson(json["series"]), // <--- ALTERADO AQUI
            author: ReviewAuthor.fromJson(json["author"]),
        );
    }
}

/// Modelo para o objeto aninhado 'author'
class ReviewAuthor {
    final String id;
    final String username;
    final String? avatarUrl; // '?' indica que pode ser nulo

    ReviewAuthor({
        required this.id,
        required this.username,
        this.avatarUrl,
    });

    /// Cria uma instância de [ReviewAuthor] a partir de um mapa JSON.
    factory ReviewAuthor.fromJson(Map<String, dynamic> json) => ReviewAuthor(
        id: json["id"],
        username: json["username"],
        // Mapeia 'avatar_url' do JSON para 'avatarUrl' no Dart
        avatarUrl: json["avatar_url"], 
    );
}