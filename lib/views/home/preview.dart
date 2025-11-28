import 'package:flutter/material.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/review_card_in_serie.dart';

class Preview extends StatelessWidget {
  const Preview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 300),
        ReviewCardInSerie(review: meuReview),
      ],
    );
  }
}

// 1. Primeiro, criamos as instâncias dos objetos aninhados

final autorDaReview = ReviewAuthor(
  id: "user_abc_123",
  username: "alicce",
  avatarUrl:
      "https://www.evanescence.com/wp-content/uploads/2016/09/EV5_FALLEN_1200X1200.jpg", // URL de exemplo
);

final serieDaReview = SerieModel(
  id: "series_xyz_789",
  name: "Hannibal",
  posterUrl:
      "https://www.themoviedb.org/t/p/w600_and_h900_bestv2/pbV2eLnKSIm1epSZt473UYfqaeZ.jpg", // URL de exemplo
  // --- Campos adicionais exigidos pelo SerieModel ---
  popularity: 95.8, // Valor de exemplo
  originalName: "Hannibal", // Valor de exemplo
  backgroundUrl: null, // URL de exemplo
  overview:
      "A série explora a relação inicial entre o renomado psiquiatra Hannibal Lecter e seu paciente, o jovem analista criminal do FBI, Will Graham, que é assombrado por sua habilidade de ter empatia com assassinos em série.", // Valor de exemplo
);

// 2. Agora, criamos a instância principal do Review,
//    passando os objetos que acabamos de criar.

final meuReview = ReviewModel(
  id: 1,
  seasonNumber: null, // Nulo = é review da série geral
  episodeNumber: null,
  stars: 4.5,
  liked: true,
  content: "jkdaskfjdsfskj", // Veio nulo no JSON
  series: ReviewSeries(
    id: 121,
    name: "Doctor Who",
    posterUrl: "https://image.tmdb.org/t/p/w500/uvxLuymTnNeFyiphc8YpCU91agb.jpg",
    // Adicione outros campos obrigatórios do seu SerieModel aqui, se houver
  ),
  author: ReviewAuthor(
    id: "f2604305-ada5-4e9e-b8a3-d96ead426bbd",
    username: "silent_lion_1225",
    avatarUrl: "https://lh3.googleusercontent.com/a/ACg8ocKeAKan4bqWubHJYfpWS80GZ8CQxWylD8iEABqz98wn2USix2E=s96-c",
  ),
);