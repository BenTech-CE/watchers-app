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
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/utils/number.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';

class ListDetailsPage extends StatefulWidget {
  const ListDetailsPage({super.key});

  @override
  State<ListDetailsPage> createState() => _ListDetailsPageState();
}

class _ListDetailsPageState extends State<ListDetailsPage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  ListModel? list;
  ListAdditionalData? additionalData;

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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
        list = listArg;
      });

      final listsProvider = context.read<ListsProvider>();
      
      final FullListModel? fullList = await listsProvider.getListDetails(listArg.id.toString());
      if (fullList != null && mounted) {
        setState(() {
          additionalData = fullList.additionalData;
        });
      }

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

    final randomBackground = additionalData != null && additionalData!.series.isNotEmpty
        ? additionalData!.series[0].backgroundUrl
        : null;

    return list != null ? Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(_appBarOpacity),
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "Lista",
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
                              list?.name ?? "",
                              style: AppTextStyles.titleLarge
                                  .copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                            ),
                            Text(
                              list?.description ?? "",
                              style: AppTextStyles.bodyMedium
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
                                      arguments: list?.author.id,
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 16, 
                                    backgroundColor: Colors.grey[800],
                                    backgroundImage: list?.author.avatarUrl != null
                                        ? NetworkImage(list!.author.avatarUrl!)
                                        : null,
                                    child: list?.author.avatarUrl == null
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
                                        arguments: list?.author.id,
                                      );
                                    },
                                    child: Text(
                                      list?.author.fullName != null && list!.author.fullName!.isNotEmpty ? list!.author.fullName! : "@${list!.author.username}",
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      size: 20,
                                      color: Color(0xFF747474) //Color(0xFFCC4A4A),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (list?.likeCount ?? 0).toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Iconify(
                                      Mdi.comment_multiple,
                                      size: 20,
                                      color: Color(0xFF747474),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "0", // Comentários não implementados ainda
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14
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
                                  for (ListLikedUser user in additionalData?.likedBy ?? [])
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
                                  if ((list?.likeCount ?? 0) > 10)
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
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.grey[700],
                                      // Substituir pelo avatar do usuário logado
                                      child: userProvider.currentUser?.avatarUrl != null
                                          ? Image.network(userProvider.currentUser!.avatarUrl!)
                                          : const Icon(Icons.person, color: Colors.white)
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
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
                                      onTap: () {
                                        // Ação de enviar comentário (não implementada)
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Iconify(Ion.send_outline, color: tColorPrimary, size: 20)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
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