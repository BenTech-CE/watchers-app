import 'package:flutter/material.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/review_card.dart';

class Preview extends StatelessWidget {
  const Preview({super.key});


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 300,),
        ReviewCard(review: meuReview)
      ],
    );
  }
}

// 1. Primeiro, criamos as instâncias dos objetos aninhados

final autorDaReview = ReviewAuthor(
  id: "user_abc_123",
  username: "alicce",
  avatarUrl: null, // URL de exemplo
);

final serieDaReview = SerieModel(
  id: "series_xyz_789",
  name: "Hannibal",
  posterUrl: "https://image.tmdb.org/t/p/w500/eDn8XWA0a4U3zOhd1gh7HExdt4Y.jpg", // URL de exemplo
  
  // --- Campos adicionais exigidos pelo SerieModel ---
  popularity: 95.8, // Valor de exemplo
  originalName: "Hannibal", // Valor de exemplo
  backgroundUrl: null, // URL de exemplo
  overview: "A série explora a relação inicial entre o renomado psiquiatra Hannibal Lecter e seu paciente, o jovem analista criminal do FBI, Will Graham, que é assombrado por sua habilidade de ter empatia com assassinos em série.", // Valor de exemplo
);

// 2. Agora, criamos a instância principal do Review,
//    passando os objetos que acabamos de criar.

final meuReview = ReviewModel(
  id: "review_id_001",
  type: "season", // "season", "episode" ou "series"
  reviewed: "Temporada 1", // Opcional, mas se encaixa no card
  stars: 4.0, // 4 estrelas cheias
  liked: true, // O coração estava vermelho
  content: "Adorei essa temporada, espero que continue assim nas próximas temporadas.",
  series: serieDaReview,
  author: autorDaReview,
);