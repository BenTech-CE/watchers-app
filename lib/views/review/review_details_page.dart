import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/reviews/full_review_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:intl/intl.dart';
import 'package:watchers/core/utils/number.dart';
import 'package:watchers/widgets/comment_card.dart';
import 'package:watchers/widgets/yes_no_dialog.dart';

class ReviewDetailsPage extends StatefulWidget {
  const ReviewDetailsPage({super.key});

  @override
  State<ReviewDetailsPage> createState() => _ReviewDetailsPageState();
}

class _ReviewDetailsPageState extends State<ReviewDetailsPage> with WidgetsBindingObserver {
  late TextEditingController _commentTextController;

  ReviewModel? review;
  ReviewAdditionalData? additionalData;

  final ScrollController _scrollController = ScrollController();
  int _appBarOpacity = 0;
  double _gradientOpacity = 0.0;

  void _updateGradientOpacity() {
    // Calcula opacidade baseada no scroll (0-150px)
    final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
    final gradientOp = (offset / 150).clamp(0.0, 1.0);

    if (_gradientOpacity != gradientOp) {
      setState(() {
        _appBarOpacity = gradientOp == 1 ? 255 : 0;
        _gradientOpacity = gradientOp;
      });
    }
  }

  void _onScroll() {
    _updateGradientOpacity();
  }

  void _comment() async {
    final reviewsProvider = context.read<ReviewsProvider>();
    final userProvider = context.read<UserProvider>();

    if (additionalData == null || review == null) return;

    final commentText = _commentTextController.text.trim();
    if (commentText.isEmpty) return;

    final newComment = await reviewsProvider.addComment(review!.id.toString(), commentText);

    if (newComment != null && mounted) {
      additionalData!.commentCount += 1;
      additionalData!.comments.insert(0, newComment);

      _commentTextController.clear();
      setState(() {});
    }

    if (reviewsProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));
    }
  }

  void _deleteComment(int commentId) async {
    final reviewsProvider = context.read<ReviewsProvider>();

    if (additionalData == null || review == null) return;

    final willDelete = await showDialog<bool>(
      context: context,
      builder: (context) => YesNoDialog(
        title: "Excluir Comentário",
        content: "Você tem certeza que deseja excluir este comentário?",
        cta: "Excluir",
      ),
    );

    if (willDelete == null || !willDelete) return;

    await reviewsProvider.deleteComment(review!.id.toString(), commentId.toString());

    if (reviewsProvider.errorMessage == null && mounted) {
      additionalData!.commentCount -= 1;
      additionalData!.comments.removeWhere((c) => c.id == commentId);

      setState(() {});
    } else if (reviewsProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));
    }
  }

  void _like() async {
    final reviewsProvider = context.read<ReviewsProvider>();
    final userProvider = context.read<UserProvider>();

    if (additionalData == null || review == null) return;

    if (additionalData!.userLiked) {
      additionalData!.likeCount -= 1;
      additionalData!.likedBy.removeWhere((user) => user.id == userProvider.currentUser!.id);
    } else {
      additionalData!.likeCount += 1;
      additionalData!.likedBy.insert(0, ReviewLikedUser(id: userProvider.currentUser!.id, avatarUrl: userProvider.currentUser!.avatarUrl));
    }
    additionalData!.userLiked = !additionalData!.userLiked;

    setState(() {});

    if (additionalData!.userLiked) {
      await reviewsProvider.like(review!.id.toString());
    } else {
      await reviewsProvider.unlike(review!.id.toString());
    }

    if (reviewsProvider.errorMessage != null && mounted) {
      // Reverter mudança em caso de erro
      if (additionalData!.userLiked) {
        additionalData!.likeCount -= 1;
        additionalData!.likedBy.removeWhere((user) => user.id == userProvider.currentUser!.id);
      } else {
        additionalData!.likeCount += 1;
        additionalData!.likedBy.insert(0, ReviewLikedUser(id: userProvider.currentUser!.id, avatarUrl: userProvider.currentUser!.avatarUrl));
      }
      additionalData!.userLiked = !additionalData!.userLiked;

      setState(() {});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Chamado quando o teclado aparece/desaparece
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateGradientOpacity();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _commentTextController = TextEditingController();
  
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final rev = ModalRoute.of(context)!.settings.arguments as ReviewModel;

      setState(() {
        review = rev;
      });

      final reviewsProvider = context.read<ReviewsProvider>();
      
      final FullReviewModel? fullReview = await reviewsProvider.getReviewById(rev.id.toString());
      if (fullReview != null && mounted) {
        setState(() {
          additionalData = fullReview.additionalData;
        });
      }

      if (reviewsProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(reviewsProvider.errorMessage!)));

        Navigator.pop(context);
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

    final userProvider = context.watch<UserProvider>();
    final reviewsProvider = context.watch<ReviewsProvider>();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return review != null ? Scaffold(
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
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Espaço vazio que permite scroll até o topo
                const SizedBox(height: 300),
                // Container com conteúdo
                Container(
                  width: double.infinity,
                  padding:  EdgeInsets.fromLTRB(
                    0,
                    0,
                    0,
                    bottomPadding + 16,
                  ),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IntrinsicHeight(
                              child: Row(
                                spacing: 16,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: cardHeight,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            review?.series.name ?? "",
                                            style: AppTextStyles.titleLarge
                                                .copyWith(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (review?.type == "season" ||
                                            review?.type == "episode")
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0,
                                              vertical: 2.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorTertiary.withOpacity(0.4),
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Text(
                                              review?.type == "season"
                                                  ? "Temporada ${review?.seasonNumber}"
                                                  : "Temporada ${review?.seasonNumber} • Episódio ${review?.episodeNumber}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Avatar
                                          Row(
                                            spacing: 8,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/profile',
                                                    arguments: review?.author.id,
                                                  );
                                                },
                                                child: CircleAvatar(
                                                  radius: 16, 
                                                  backgroundColor: Colors.grey[800],
                                                  backgroundImage: review?.author.avatarUrl != null
                                                      ? NetworkImage(review!.author.avatarUrl!)
                                                      : null,
                                                  child: review?.author.avatarUrl == null
                                                      ? const Icon(Icons.person, color: Colors.white)
                                                      : null,
                                                ),
                                              ),
                                              
                                              // Nome do Usuário
                                              Expanded(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/profile',
                                                      arguments: review?.author.id,
                                                    );
                                                  },
                                                  child: Text(
                                                    review?.author.fullName != null && review!.author.fullName!.isNotEmpty ? review!.author.fullName! : "@${review!.author.username}",
                                                    style: const TextStyle(
                                                      color: tColorPrimary,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                    
                                          ),
                                          const SizedBox(height: 12),
                                          // Avaliação (estrelas + coração)
                                          Row(
                                            children: [
                                                // Estrelas
                                              ..._buildStarRating(review?.stars ?? 0),
                                              const SizedBox(width: 8),
                                              // Ícone de Coração
                                              Icon(
                                                review?.liked ?? false ? Icons.favorite : Icons.favorite_border,
                                                color: review?.liked ?? false ? const Color(0xFFCC4A4A) : Colors.grey[600],
                                                size: 20,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/series/detail', arguments: review?.series.id.toString());
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: review?.series.posterUrl ?? "",
                                        width: cardWidth,
                                        height: cardHeight,
                                        errorWidget: (context, url, error) => Container(
                                          width: cardWidth,
                                          height: cardHeight,
                                          color: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              review?.content ?? "",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14
                              )
                            ),
                            if (additionalData?.createdAt != null)
                              _buildDateInfo(),
                            if (additionalData != null)
                            Row(
                              spacing: 24,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _like,
                                  child: Row(
                                    children: [
                                      Icon(
                                        additionalData?.userLiked ?? false ? Icons.favorite : Icons.favorite_outline,
                                        size: 24,
                                        color: additionalData?.userLiked ?? false ? Color(0xFFCC4A4A) : Color(0xFF747474),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (additionalData?.likeCount ?? 0).toCompactString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Iconify(
                                      Mdi.comment_multiple,
                                      size: 24,
                                      color: Color(0xFF747474),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (additionalData?.commentCount ?? 0).toCompactString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (additionalData != null && additionalData!.likeCount > 0)
                            const Text(
                              'Curtido por',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (additionalData != null && additionalData!.likeCount > 0)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 8,
                                children: [
                                  for (ReviewLikedUser user in additionalData?.likedBy ?? [])
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/profile',
                                          arguments: user.id,
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Colors.grey[800],
                                        backgroundImage: user.avatarUrl != null
                                            ? NetworkImage(user.avatarUrl!)
                                            : null,
                                        child: user.avatarUrl == null
                                            ? const Icon(Icons.person, color: Colors.white)
                                            : null,
                                      ),
                                    ),
                                  if ((additionalData?.likeCount ?? 0) > 10)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+${(additionalData!.likeCount - 10).toCompactString()}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox.shrink(),
                            const Text(
                              'Comentários',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(12, 0, 4, 0),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[700],
                                    backgroundImage: userProvider.currentUser?.avatarUrl != null
                                        ? NetworkImage(userProvider.currentUser!.avatarUrl!)
                                        : null,
                                    child: userProvider.currentUser?.avatarUrl == null
                                        ? const Icon(Icons.person, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _commentTextController,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        hintText: "Comente sobre a resenha...",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: reviewsProvider.isLoadingAction ? null : _comment,
                                      child: reviewsProvider.isLoadingAction ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(
                                            color: tColorPrimary,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ) : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Iconify(Ion.send_outline, color: tColorPrimary, size: 20)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (additionalData != null)
                              ...additionalData!.comments.map((comment) => CommentCard(comment: comment, onPressDelete: () { _deleteComment(comment.id); },))
                          ]
                        )
                      )
                    ]
                  )
                )
              ]
            )
          )
        ]
      )
    ) : const Scaffold(
      body: Center(),
    );
  }

  /// Helper para construir a lista de ícones de estrela
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      } else {
        iconData = Icons.star_border;
      }
      // Ajustei levemente o tamanho e cor para bater com a imagem 'violet'
      stars.add(Icon(iconData, color: Colors.amber, size: 20));
    }
    return stars;
  }

  /// Helper para construir informação de data
  Widget _buildDateInfo() {
    final createdAt = DateTime.parse(additionalData!.createdAt).toLocal();
    final updatedAt = additionalData?.updatedAt != null 
        ? DateTime.parse(additionalData!.updatedAt!).toLocal()
        : null;
    
    final wasEdited = updatedAt != null && 
        updatedAt.difference(createdAt).inMinutes > 1;

    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Publicada em ${dateFormat.format(createdAt)}",
          style: AppTextStyles.bodySmall.copyWith(
            color: tColorSecondary,
          ),
        ),
        if (wasEdited)
          Text(
            "Editada em ${dateFormat.format(updatedAt!)}",
            style: AppTextStyles.bodySmall.copyWith(
              color: tColorSecondary,
            ),
          ),
      ],
    );
  }
}