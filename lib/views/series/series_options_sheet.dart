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
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:iconify_flutter/icons/oi.dart';
import 'package:watchers/widgets/star_rating.dart';

class SeriesOptionsSheet extends StatefulWidget {
  final String title;
  final String id;
  final String scope;
  final bool isSeries;
  final String? posterPath;
  final String? logoPath;
  final int? seasonNumber;
  final int? episodeNumber;

  const SeriesOptionsSheet({
    super.key,
    required this.title,
    required this.id,
    required this.scope,
    required this.isSeries,
    this.seasonNumber,
    this.episodeNumber,
    this.posterPath,
    this.logoPath,
  });

  @override
  State<SeriesOptionsSheet> createState() => _SeriesOptionsSheetState();
}

//String iconWatched =
//    '<svg xmlns="http://www.w3.org/2000/svg" width="572" height="512" viewBox="0 0 572 512"><path fill="currentColor" d="M572.52 241.4C518.29 135.59 410.93 64 288 64S57.68 135.64 3.48 241.41a32.35 32.35 0 0 0 0 29.19C57.71 376.41 165.07 448 288 448s230.32-71.64 284.52-177.41a32.35 32.35 0 0 0 0-29.19M288 400a144 144 0 1 1 144-144a143.93 143.93 0 0 1-144 144m0-240a95.3 95.3 0 0 0-25.31 3.79a47.85 47.85 0 0 1-66.9 66.9A95.78 95.78 0 1 0 288 160"/></svg>';

class _SeriesOptionsSheetState extends State<SeriesOptionsSheet> {
  double rating = 0;
  bool watched = false;
  bool liked = false;
  bool watchlist = false;

  void updateProviderState({
    bool? newWatched,
    bool? newLiked,
    bool? newWatchlist,
    double? newStars,
    int? newReviewId,
  }) {
    final userProvider = context.read<UserProvider>();
    final current = userProvider.currentUserInteractionData(widget.scope);

    userProvider.setCurrentUserInteractionData(
      widget.scope,
      UserInteractionData(
        isWatched: newWatched ?? watched, // Usa o novo ou o local atual
        isLiked: newLiked ?? liked,
        inWatchlist: newWatchlist ?? watchlist,
        stars:
            newStars ??
            (rating != 0
                ? rating
                : current.stars), // Ajuste conforme sua var rating
        reviewId: newReviewId ?? current.reviewId,
        reviewText: current.reviewText,
      ),
    );
  }

  void changeWatched() async {
    final userProvider = context.read<UserProvider>();

    // 1. Guarda o estado anterior para caso precise desfazer (Rollback)
    final previousWatched = watched;

    // 2. Atualiza Estado Local e Provider Otimisticamente
    setState(() {
      watched = !watched;
    });
    updateProviderState(newWatched: watched);

    try {
      // 3. Chama a API
      if (previousWatched) {
        // Se estava assistido, vamos remover
        await userProvider.deleteSeriesWatched(
          [widget.id],
          widget.seasonNumber,
          widget.episodeNumber,
        );
      } else {
        // Se não estava, vamos adicionar
        await userProvider.addSeriesWatched(
          [widget.id],
          widget.seasonNumber,
          widget.episodeNumber,
        );
      }

      // Verifica erro de negócio da API
      if (userProvider.errorMessage != null) {
        throw Exception(userProvider.errorMessage);
      }
    } catch (e) {
      // 4. ROLLBACK: Se deu erro, desfaz tudo
      if (mounted) {
        setState(() {
          watched = previousWatched; // Volta o valor antigo
        });
        updateProviderState(newWatched: previousWatched); // Volta o provider

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar assistido: $e')),
        );
      }
    }
  }

  void changeWatchlist() async {
    final userProvider = context.read<UserProvider>();
    final previousWatchlist = watchlist;

    // Otimista
    setState(() {
      watchlist = !watchlist;
    });
    updateProviderState(newWatchlist: watchlist);

    try {
      if (previousWatchlist) {
        await userProvider.deleteSeriesWatchlist(
          [widget.id],
          widget.seasonNumber,
          widget.episodeNumber,
        );
      } else {
        await userProvider.addSeriesWatchlist(
          [widget.id],
          widget.seasonNumber,
          widget.episodeNumber,
        );
      }

      if (userProvider.errorMessage != null) {
        throw Exception(userProvider.errorMessage);
      }
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() {
          watchlist = previousWatchlist;
        });
        updateProviderState(newWatchlist: previousWatchlist);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro na watchlist: $e')));
      }
    }
  }

  void changeLiked() async {
    final userProvider = context.read<UserProvider>();
    final previousLiked = liked;

    // Otimista
    setState(() {
      liked = !liked;
    });
    // Note: Ainda não temos o ID novo se for criado agora, mas atualizamos a UI visual
    updateProviderState(newLiked: liked);

    ReviewModel review = ReviewModel(
      id: null,
      stars: rating != 0 ? rating.toDouble() : null,
      content: userProvider.currentUserInteractionData(widget.scope).reviewText,
      liked: liked, // O novo valor
      series: ReviewSeries(
        id: 0,
        name: '',
      ), // Dados mock para o envio, se necessário
      author: ReviewAuthor(id: '', username: ''),
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
    );

    try {
      final savedReview = await userProvider.saveReviewSeries(
        review,
        widget.id,
      );

      if (userProvider.errorMessage != null) {
        throw Exception(userProvider.errorMessage);
      }

      // SUCESSO: A API retornou a review salva.
      // É CRUCIAL atualizar o Provider com o ID que veio do servidor
      // caso tenha sido criada uma nova review (interação) agora.
      if (mounted) {
        updateProviderState(
          newLiked: savedReview.liked,
          newReviewId: savedReview.id, // Atualiza o ID para persistência futura
          newStars: savedReview.stars,
        );
      }
    } catch (e) {
      // Rollback
      if (mounted) {
        setState(() {
          liked = previousLiked;
        });
        updateProviderState(newLiked: previousLiked);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao curtir: $e')));
      }
    }
  }

  void changeRating(double newRating) async {
    final userProvider = context.read<UserProvider>();

    // 1. Guarda o valor antigo para Rollback
    final previousRating = rating;

    // 2. Atualização Otimista (UI + Provider Local)
    setState(() {
      rating = newRating;
    });

    // Usa o helper criado na resposta anterior para propagar a mudança
    updateProviderState(newStars: newRating);

    // 3. Monta o objeto Review preservando os outros dados (like, texto)
    ReviewModel review = ReviewModel(
      id: null, // Mantém ID se existir
      stars: newRating, // O valor novo
      content: userProvider
          .currentUserInteractionData(widget.scope)
          .reviewText, // Mantém o texto atual
      liked: liked, // Mantém o status de like atual
      series: ReviewSeries(id: 0, name: ''), // Boilerplate
      author: ReviewAuthor(id: '', username: ''), // Boilerplate
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
    );

    try {
      // 4. Chama a API
      final savedReview = await userProvider.saveReviewSeries(
        review,
        widget.id,
      );

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

  void _navigateToAddReview() {
    final UserProvider userProvider = context.read<UserProvider>();
    final currentInteraction =
        userProvider.currentUserInteractionData(widget.scope);
    final String? content = currentInteraction.reviewText;

    Navigator.pushReplacementNamed(
      context,
      '/review/add',
      arguments: {
        "title": widget.title,
        "id": widget.id,
        "content": content,
        "scope": widget.scope,
        "posterPath": widget.posterPath,
        "logoPath": widget.logoPath,
        "seasonNumber": widget.seasonNumber,
        "episodeNumber": widget.episodeNumber,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    // Inicializa o estado com base nos dados da série

    watched = userProvider.currentUserInteractionData(widget.scope).isWatched;
    liked = userProvider.currentUserInteractionData(widget.scope).isLiked;
    watchlist = userProvider
        .currentUserInteractionData(widget.scope)
        .inWatchlist;
    rating = (userProvider.currentUserInteractionData(widget.scope).stars ?? 0)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      "Avalie",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(width: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.2,
                        color: colorTertiary,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            LineSeparator(),

            const SizedBox(height: 16),

            // ===== ICON ROW =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: widget.isSeries
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  _iconAction(
                    icon: Oi.eye,
                    label: widget.isSeries ? "Completo" : "Assistido",
                    active: watched,
                    index: 0,
                    onTap: changeWatched,
                  ),
                  _iconAction(
                    icon: Mdi.heart,
                    label: "Gostei",
                    active: liked,
                    index: 1,
                    onTap: changeLiked,
                  ),
                  _iconAction(
                    icon: Cil.clock,
                    label: "Watchlist",
                    active: watchlist,
                    index: 2,
                    onTap: changeWatchlist,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ===== STAR RATING =====
            Center(
              child: StarRating(
                rating: rating,
                onRatingChanged: (newRating) {
                  changeRating(newRating);
                },
                size: 50,
                spacing: 6,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Sua nota",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 16),

            LineSeparator(),

            // ===== OPTIONS LIST =====
            /*if (widget.isSeries)
              _optionTile(
                icon: Oi.eye,
                title: "Marcar como assistido",
                trailing: _tag("Temporada"),
                onTap: () {},
              ),

            if (widget.isSeries)
              _optionTile(
                icon: Cil.clock,
                title: "Adicionar à watchlist",
                trailing: _tag("Temporada"),
                onTap: () {},
              ),
            */

            //const SizedBox(height: 8),
            _optionTile(
              icon: Majesticons.pencil_alt_line,
              title: "Escrever resenha",
              onTap: () {
                _navigateToAddReview();
              },
            ),

            /*
            if (widget.isSeries)
              _optionTile(
                icon: MaterialSymbols.list,
                title: "Adicionar em uma lista",
                onTap: () {},
              ),
              */
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== ICON BUTTON =====
  Widget _iconAction({
    required String icon,
    required String label,
    required bool active,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Iconify(
            icon,
            color: active
                ? index == 1
                      ? Color(0xFFCC4A4A)
                      : Color(0xFF7087FF)
                : Color(0xFF8D8D8D),
            size: 46,
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ===== OPTION TILE =====
  Widget _optionTile({
    required String icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,

      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Iconify(icon, color: Color(0xFF8D8D8D), size: 30),
      title: Text(title),
      trailing: trailing,
    );
  }

  // ===== TAG =====
  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF8D8D8D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          SizedBox(width: 8, height: 0),
          const Iconify(
            '<svg width="12" height="7" viewBox="0 0 12 7" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.800049 0.799988L5.80005 5.79999L10.8 0.799988" stroke="#8D8D8D" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>',
            size: 8,
          ),
        ],
      ),
    );
  }
}
