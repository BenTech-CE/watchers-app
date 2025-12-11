import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/reviews/full_review_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/theme/texts.dart';

class ListDetailsPage extends StatefulWidget {
  const ListDetailsPage({super.key});

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> {
  ReviewModel? review;
  ReviewAdditionalData? additionalData;

  final ScrollController _scrollController = ScrollController();
  int _appBarOpacity = 0;
  double _gradientOpacity = 0.0;

  void _onScroll() {
    // Calcula opacidade baseada no scroll (0-200px)
    final offset = _scrollController.offset;
    final gradientOp = (offset / 150).clamp(0.0, 1.0);

    if (_gradientOpacity != gradientOp) {
      setState(() {
        _appBarOpacity = gradientOp == 1 ? 255 : 0;
        _gradientOpacity = gradientOp;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rev = ModalRoute.of(context)!.settings.arguments as ReviewModel;

      final reviewsProvider = context.read<ReviewsProvider>();
      
      final FullReviewModel? fullReview = await reviewsProvider.getReviewById(rev.id.toString());
      if (fullReview != null && mounted) {
        setState(() {
          review = fullReview.reviewData;
          additionalData = fullReview.additionalData;
        });
      }

      if (reviewsProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // variaveis para o taman ho do poster (25% da tela, proporção 2:3)
    const double cardWidthFraction = 0.25;
    const double aspectRatio = 2 / 3;
    final double cardWidth =
        MediaQuery.of(context).size.width * cardWidthFraction;
    final double cardHeight = cardWidth / aspectRatio;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(_appBarOpacity),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Resenha",
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Imagem de fundo fixa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(1),
                    Colors.black.withOpacity(_gradientOpacity),
                    Colors.black.withOpacity(_gradientOpacity),
                    Colors.black.withOpacity(_gradientOpacity),
                    Colors.black.withOpacity(1),
                  ],
                  stops: const [0.0, 0.3, 0.4, 0.5, 1.0],
                ),
              ),
              child: (additionalData == null || additionalData?.backgroundUrl == null) ? SizedBox(
                width: double.infinity,
                height: 350,
                child: Container(color: Colors.black),
              ) : CachedNetworkImage(
                imageUrl: additionalData!.backgroundUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 350,
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 350,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Conteúdo scrollável
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Espaço vazio que permite scroll até o topo
                const SizedBox(height: 300),
                // Container com conteúdo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    kBottomNavigationBarHeight + 16,
                  ),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("oi")
                    ]
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}