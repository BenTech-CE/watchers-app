import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/full_list_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/full_review_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/utils/number.dart';
import 'package:watchers/views/list/list_options_sheet.dart';
import 'package:watchers/widgets/comment_card.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';
import 'package:watchers/widgets/yes_no_dialog.dart';

class ListDetailsPage extends StatefulWidget {
  const ListDetailsPage({super.key});

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextEditingController _commentTextController;

  ListModel? listArg;

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
    _animationController.dispose();
    _commentTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _commentTextController = TextEditingController();

    _animationController = AnimationController( 
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final listArg = ModalRoute.of(context)!.settings.arguments as ListModel;

      setState(() {
        this.listArg = listArg;
      });

      final listsProvider = context.read<ListsProvider>();
      
      await listsProvider.getListDetails(listArg.id.toString());

      if (listsProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));

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

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final listsProvider = context.watch<ListsProvider>();
    final list = listsProvider.currentListDetails != null ? listsProvider.currentListDetails!.listData : listArg;
    final additionalData = listsProvider.currentListDetails?.additionalData;

    final randomBackground = additionalData != null && additionalData.series.isNotEmpty
        ? additionalData.series[0].backgroundUrl
        : null;

    void _like() async {
      final listsProvider = context.read<ListsProvider>();
      final userProvider = context.read<UserProvider>();

      if (additionalData == null || list == null) return;

      if (additionalData!.userLiked) {
        list!.likeCount -= 1;
        additionalData!.likedBy.removeWhere((user) => user.id == userProvider.currentUser!.id);
      } else {
        list!.likeCount += 1;
        additionalData!.likedBy.insert(0, ListLikedUser(id: userProvider.currentUser!.id, avatarUrl: userProvider.currentUser!.avatarUrl));
      }
      additionalData!.userLiked = !additionalData!.userLiked;

      setState(() {});

      if (additionalData!.userLiked) {
        await listsProvider.like(list!.id.toString());
      } else {
        await listsProvider.unlike(list!.id.toString());
      }

      if (listsProvider.errorMessage != null && mounted) {
        // Reverter mudança em caso de erro
        if (additionalData!.userLiked) {
          list!.likeCount -= 1;
          additionalData!.likedBy.removeWhere((user) => user.id == userProvider.currentUser!.id);
        } else {
          list!.likeCount += 1;
          additionalData!.likedBy.insert(0, ListLikedUser(id: userProvider.currentUser!.id, avatarUrl: userProvider.currentUser!.avatarUrl));
        }
        additionalData!.userLiked = !additionalData!.userLiked;

        setState(() {});

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
      }
    }

    void _comment() async {
      if (additionalData == null || list == null) return;

      final commentText = _commentTextController.text.trim();
      if (commentText.isEmpty) return;

      final newComment = await listsProvider.addComment(list!.id.toString(), commentText);

      if (newComment != null && mounted) {
        list!.commentCount += 1;
        additionalData!.comments.insert(0, newComment);

        _commentTextController.clear();
        setState(() {});
      }

      if (listsProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
      }
    }

    void _deleteComment(int commentId) async {
      if (additionalData == null || list == null) return;

      final willDelete = await showDialog<bool>(
        context: context,
        builder: (context) => YesNoDialog(
          title: "Excluir Comentário",
          content: "Você tem certeza que deseja excluir este comentário?",
          cta: "Excluir",
        ),
      );

      if (willDelete == null || !willDelete) return;

      await listsProvider.deleteComment(list!.id.toString(), commentId.toString());

      if (listsProvider.errorMessage == null && mounted) {
        list!.commentCount -= 1;
        additionalData!.comments.removeWhere((c) => c.id == commentId);

        setState(() {});
      } else if (listsProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
      }
    }

    return list != null ? Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(_appBarOpacity),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          list.name ?? "",
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (list.author.id == userProvider.currentUser?.id && additionalData != null)
            IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (BuildContext context) => ListOptionsSheet(),
                );
              },
              icon: Icon(Icons.settings, color: tColorPrimary)
            ),
        ],
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
              child: (randomBackground == null) ? SizedBox(
                width: double.infinity,
                height: 350,
                child: Container(color: Colors.black),
              ) : CachedNetworkImage(
                imageUrl: randomBackground,
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
                            Text(
                              list.name ?? "",
                              style: AppTextStyles.titleLarge
                                  .copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            Text(
                              list.description ?? "",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14
                              )
                            ),                      
                            // Avatar
                            Row(
                              spacing: 8,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/profile',
                                      arguments: list.author.id,
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 16, 
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage: list.author.avatarUrl != null
                                        ? NetworkImage(list!.author.avatarUrl!)
                                        : null,
                                    child: list.author.avatarUrl == null
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
                                        arguments: list.author.id,
                                      );
                                    },
                                    child: Text(
                                      list.author.fullName != null && list!.author.fullName!.isNotEmpty ? list!.author.fullName! : "@${list!.author.username}",
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
                            Row(
                              spacing: 24,
                              children: [
                                GestureDetector(
                                  onTap: _like,
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      Icon(
                                        additionalData?.userLiked ?? false ? Icons.favorite : Icons.favorite_outline,
                                        size: 24,
                                        color: additionalData?.userLiked ?? false ? Color(0xFFCC4A4A) : Color(0xFF747474),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (list?.likeCount ?? 0).toCompactString(),
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
                                      (list.commentCount ?? 0).toCompactString(), // Comentários não implementados ainda
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
                            if (additionalData == null)
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2 / 3,
                                ),
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  return SerieSkeletonCard(animation: _animation,);
                                },
                              ),
                            if (additionalData != null)
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2 / 3,
                                ),
                                itemCount: additionalData!.series.length,
                                itemBuilder: (context, index) {
                                  final series = additionalData!.series[index];
                                  return ImageCard(
                                    url: series.posterUrl,
                                    animation: _animation,
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/series/detail',
                                        arguments: series.id.toString(),
                                      );
                                    },
                                  );
                                },
                              ),
                            if (additionalData != null && list!.likeCount > 0)
                            const Text(
                              'Curtido por',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (additionalData != null && list!.likeCount > 0)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 8,
                                children: [
                                  for (ListLikedUser user in additionalData.likedBy ?? [])
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/profile',
                                          arguments: user.id,
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(999),
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
                                    ),
                                  if ((list.likeCount ?? 0) > 10)
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[900],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+${(list!.likeCount - 10).toCompactString()}",
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
                                        hintText: "Comente sobre a lista...",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Material(
                                    borderRadius: BorderRadius.circular(999),
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(999),
                                      onTap: listsProvider.isLoadingAction ? null : _comment,
                                      child: listsProvider.isLoadingAction ? Padding(
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
                              ...additionalData.comments.map((comment) => CommentCard(comment: comment, onPressDelete: () {
                                _deleteComment(comment.id);
                              },))
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
}