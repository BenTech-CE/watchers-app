import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:watchers/widgets/card_skeleton.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/series_card.dart';
import 'package:watchers/widgets/stars_chart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<SerieModel> watchedSeries = [];
  List<SerieModel> favoritedSeries = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchUserData() {
    final userProvider = context.read<UserProvider>();
    userProvider.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile/edit');
            },
            icon: Icon(Icons.settings, color: tColorPrimary)
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: IntrinsicHeight(
                child: Row(
                  // 2. Isso força a Column de texto a esticar para a mesma altura da imagem (100px)
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ImageCard(
                        url: authInfo.user?.avatarUrl,
                        onTap: () {},
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(width: 20), // Espaçamento entre imagem e texto
                    // 3. Use Expanded para a coluna de texto ocupar a largura restante
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Alinha textos à esquerda
                        children: [
                          Text(
                            userProvider.currentUser?.fullName ??
                                userProvider.currentUser?.username ??
                                '',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "@${userProvider.currentUser?.username ?? ''}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: tColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProvider.currentUser?.bio ??
                                "Biografia não definida.",
                            maxLines: 2,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
              
                          // 4. O Spacer agora funciona pois a coluna tem altura fixa (100px)
                          const Spacer(),
              
                          Row(
                            spacing: 16,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${userProvider.currentUser?.followerCount ?? 0}",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Seguidores",
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          "${userProvider.currentUser?.followingCount ?? 0}",
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " Seguindo",
                                      style: AppTextStyles.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LineSeparator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Séries Favoritas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            GridView.builder(
              shrinkWrap: true, 
              // 3. Importante: Desativa a rolagem do Grid (quem rola é o SingleChildScrollView)
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              gridDelegate: 
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 23,
                  mainAxisSpacing: 23,
                  childAspectRatio: 2 / 3,
                ),
              itemCount: (userProvider.currentUser?.favorites.length ?? 0) > 3 ? 3 : userProvider.currentUser?.favorites.length ?? 0,
              itemBuilder: (context, index) {
                final series = userProvider.currentUser?.favorites[index];
                return SeriesCard(
                  series: series!,
                  isSelected: false,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/series/detail',
                      arguments: series.id,
                    );
                  },
                );
              },
            ),
            LineSeparator(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Avaliações do Usuário',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: StarsChart(data: userProvider.currentUser?.starDistribution ?? []),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.lists.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.lists.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Listas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.lists.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: userProvider.isLoadingUser
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var list in userProvider.currentUser?.lists ?? [])
                        ListPopularCard(list: list),
                    ],
                  ),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.watchlist.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.watchlist.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Assistir futuramente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.watchlist.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListSeries(series: userProvider.currentUser?.watchlist ?? []),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.reviews.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Resenhas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && userProvider.currentUser?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: userProvider.isLoadingUser
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var review in userProvider.currentUser?.reviews ?? [])
                        ReviewCard(review: review),
                    ],
                  ),
            ),
            const SizedBox(height: kToolbarHeight + 20),
          ],
        ),
      )
    );
  }
}
