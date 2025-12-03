import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
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

  FullUserModel? user;
  bool externalUser = true;

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

  void _fetchUserData() async{
    final userProvider = context.read<UserProvider>();

    dynamic userId = ModalRoute.of(context)?.settings.arguments;

    if (userId != null) {
      await userProvider.getUserById(userId);

      setState(() {
        user = userProvider.selectedUser;
        externalUser = true;        
      });

    } else {
      await userProvider.getCurrentUser();
      setState(() {
        user = userProvider.currentUser;
        externalUser = false;        
      });

    }
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
          if (!externalUser) IconButton(
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
                        url: externalUser ? user?.avatarUrl : authInfo.user?.avatarUrl,
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
                            user?.fullName ??
                                user?.username ??
                                '',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "@${user?.username ?? ''}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: tColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.bio ??
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
                                          "${user?.followerCount ?? 0}",
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
                                          "${user?.followingCount ?? 0}",
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
            if (!userProvider.isLoadingUser && user?.favorites.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && user?.favorites.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Séries Favoritas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && user?.favorites.isNotEmpty == true)
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
              itemCount: (user?.favorites.length ?? 0) > 3 ? 3 : user?.favorites.length ?? 0,
              itemBuilder: (context, index) {
                final series = user?.favorites[index];
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
              child: StarsChart(data: user?.starDistribution ?? [], onlyShowQuantity: true,),
            ),
            if (!userProvider.isLoadingUser && user?.lists.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && user?.lists.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Listas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (userProvider.isLoadingUser)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListReviewsSkeleton(itemCount: 5,)
              ),
            if (!userProvider.isLoadingUser && user?.lists.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                spacing: 12,
                children: [
                  for (var list in user?.lists ?? [])
                    ListPopularCard(list: list),
                ],
              ),
            ),
            if (!userProvider.isLoadingUser && user?.watchlist.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && user?.watchlist.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Assistir Futuramente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && user?.watchlist.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListSeries(series: user?.watchlist ?? []),
            ),
            if (!userProvider.isLoadingUser && user?.reviews.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && user?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Resenhas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && user?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: userProvider.isLoadingUser
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var review in user?.reviews ?? [])
                        ReviewCard(review: review),
                    ],
                  ),
            ),
            const SizedBox(height: kBottomNavigationBarHeight + 20),
          ],
        ),
      )
    );
  }
}
