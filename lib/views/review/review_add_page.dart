import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cil.dart';
import 'package:iconify_flutter/icons/majesticons.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:iconify_flutter/icons/oi.dart';

class ReviewAddPage extends StatefulWidget {
  const ReviewAddPage({super.key});

  @override
  State<ReviewAddPage> createState() => _ReviewAddPageState();
}

class _ReviewAddPageState extends State<ReviewAddPage> {
  late String id;
  late String title;
  late String scope;
  late String? posterPath;
  late String? logoPath;
  late int? seasonNumber;
  late int? episodeNumber;
  double rating = 0;
  bool liked = false;

  final _reviewController = TextEditingController();

  void updateProviderState({
    bool? newLiked,
    double? newStars,
    int? newReviewId,
    String? newReviewText,
  }) {
    final userProvider = context.read<UserProvider>();
    final current = userProvider.currentUserInteractionData(scope);

    userProvider.setCurrentUserInteractionData(
      scope,
      UserInteractionData(
        isWatched: current.isWatched, // Usa o novo ou o local atual
        isLiked: newLiked ?? liked,
        inWatchlist: current.inWatchlist,
        stars:
            newStars ??
            (rating != 0
                ? rating
                : current.stars), // Ajuste conforme sua var rating
        reviewId: newReviewId ?? current.reviewId,
        reviewText: newReviewText ?? current.reviewText,
      ),
    );
  }

  void changeReview(bool? newLiked, double? newRating) async {
    final userProvider = context.read<UserProvider>();

    // 1. Guarda o valor antigo para Rollback
    final previousRating = rating;

    // 2. Atualização Otimista (UI + Provider Local)
    if (newRating != null) {
      setState(() {
        rating = newRating;
      });
    }

    if (newLiked != null) {
      setState(() {
        liked = !liked;
      });
    }

    // Usa o helper criado na resposta anterior para propagar a mudança
    updateProviderState(newStars: newRating, newLiked: newLiked);

    // 3. Monta o objeto Review preservando os outros dados (like, texto)
    ReviewModel review = ReviewModel(
      id: null, // Mantém ID se existir
      stars: newRating, // O valor novo
      content: _reviewController.text,
      liked: liked, // Mantém o status de like atual
      series: ReviewSeries(id: 0, name: ''), // Boilerplate
      author: ReviewAuthor(id: '', username: ''), // Boilerplate
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
    );

    try {
      // 4. Chama a API
      final savedReview = await userProvider.saveReviewSeries(review, id);

      if (userProvider.errorMessage != null) {
        throw Exception(userProvider.errorMessage);
      }

      // 5. Sucesso: Atualiza o Provider com o retorno da API
      // Isso é crucial caso seja a primeira avaliação e um novo ID tenha sido gerado
      if (mounted) {
        updateProviderState(
          newStars: savedReview.stars,
          newReviewId: savedReview.id,
        );
      }
    } catch (e) {
      // 6. Rollback: Deu erro? Volta tudo como era antes.
      if (mounted) {
        setState(() {
          rating = previousRating;
        });
        updateProviderState(newStars: previousRating);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar classificação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    // Inicializa o estado com base nos dados da série

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    title = args['title'];
    id = args['id'];
    scope = args['scope'];
    posterPath = args['posterPath'];
    logoPath = args['logoPath'];
    seasonNumber = args['seasonNumber'];
    episodeNumber = args['episodeNumber'];

    liked = userProvider.currentUserInteractionData(scope).isLiked;
    rating = (userProvider.currentUserInteractionData(scope).stars ?? 0)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [],
        ),
      ),
    );
  }
}
