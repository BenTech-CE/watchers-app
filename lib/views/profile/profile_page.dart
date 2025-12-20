import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/akar_icons.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/fa6_solid.dart';
import 'package:iconify_flutter/icons/humbleicons.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/utils/number.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:watchers/widgets/button.dart';
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

  void _fetchUserData() async {
    final userProvider = context.read<UserProvider>();

    dynamic userId = ModalRoute.of(context)?.settings.arguments;

    if (userId != null) {
      await userProvider.getUserById(userId);

      if (mounted) {
        setState(() {
          user = userProvider.selectedUser;
          externalUser = true;        
        });
      }
    } else {
      await userProvider.getCurrentUser();
      if (mounted) {
        setState(() {
          user = userProvider.currentUser;
          externalUser = false;        
        });
      }
    }
  }

  void _refreshUserData() {
    final userProvider = context.read<UserProvider>();
    if (!externalUser) {
      setState(() {
        user = userProvider.currentUser;
      });
    }
  }

  Widget _buildChevronAction(VoidCallback onTap, [int? quantity]) {
    return Row(
      children: [
        if (quantity != null)
          Text(
            quantity.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: tColorGray)
          ),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox.square(dimension: 18, child: Iconify(Fa6Solid.chevron_right, color: tColorPrimary)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    // Atualiza user automaticamente quando o provider muda
    final displayUser = externalUser ? user : userProvider.currentUser;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    void followUnfollowUser() async {
      if (displayUser == null) return;

      final isFollowing = displayUser.isFollowing;
      final userId = displayUser.id;

      displayUser.isFollowing = !isFollowing;
      displayUser.followerCount += isFollowing ? -1 : 1;
      userProvider.currentUser?.followingCount += isFollowing ? -1 : 1;
      setState(() {});

      if (isFollowing) {
        await userProvider.unfollowUser(userId);
      } else {
        await userProvider.followUser(userId);
      }

      if (userProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));

        displayUser.isFollowing = isFollowing;
        displayUser.followerCount += isFollowing ? 1 : -1;
        userProvider.currentUser?.followingCount += isFollowing ? -1 : 1;
        setState(() {});
      }
    }

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
        physics: BouncingScrollPhysics(),
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
                    Column(
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Builder(builder: (context) {
                            /*if (_pickedImage != null) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.file(
                                  File(_pickedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else */if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user!.avatarUrl!,
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  color: bColorPrimary,
                                  child: Icon(Icons.person, size: 50, color: tColorSecondary),
                                ),
                              );
                            }
                          }),
                        ),
                      ],
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
                            displayUser?.fullName ??
                                displayUser?.username ??
                                '',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "@${displayUser?.username ?? ''}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: tColorSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            displayUser?.bio ??
                                "Biografia não definida.",
                            maxLines: 2,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 4. O Spacer agora funciona pois a coluna tem altura fixa (100px)
                          const Spacer(),
              
                          Row(
                            spacing: 16,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pushNamed(context, "/profile/follows", arguments: {
                                    'userId': displayUser?.id,
                                    'displayName': displayUser?.fullName ?? displayUser?.username ?? '',
                                    'followerCount': displayUser?.followerCount,
                                    'followingCount': displayUser?.followingCount,
                                    'initialTab': 0,
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${displayUser?.followerCount.toCompactString() ?? 0}",
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
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.pushNamed(context, "/profile/follows", arguments: {
                                    'userId': displayUser?.id,
                                    'displayName': displayUser?.fullName ?? displayUser?.username ?? '',
                                    'followerCount': displayUser?.followerCount,
                                    'followingCount': displayUser?.followingCount,
                                    'initialTab': 1,
                                  });
                                },
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "${displayUser?.followingCount.toCompactString() ?? 0}",
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
            if (!userProvider.isLoadingUser && externalUser && authInfo.user?.id != displayUser?.id)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: Button(
                  label: displayUser?.isFollowing == true ? "Seguindo" : "Seguir", 
                  onPressed: followUnfollowUser,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  variant: displayUser?.isFollowing == true ? ButtonVariant.secondary : ButtonVariant.primary,
                  trailingIcon: Iconify(displayUser?.isFollowing == true ? Mdi.user_check_outline : Mdi.user_plus_outline, size: 20, color: tColorPrimary)
                )
              ),
            ),
            if (!userProvider.isLoadingUser && displayUser?.favorites.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && displayUser?.favorites.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                'Séries Favoritas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            if (!userProvider.isLoadingUser && displayUser?.favorites.isNotEmpty == true)
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
              itemCount: (displayUser?.favorites.length ?? 0) > 3 ? 3 : displayUser?.favorites.length ?? 0,
              itemBuilder: (context, index) {
                final series = displayUser?.favorites[index];
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
              child: StarsChart(data: displayUser?.starDistribution ?? [], onlyShowQuantity: true,),
            ),
            if (!userProvider.isLoadingUser && displayUser?.watchlist.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && displayUser?.watchlist.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      if (user != null && user!.privateWatchlist) Iconify(Mdi.eye_off, size: 20, color: Colors.white,),
                      Text(
                        'Assistir Futuramente',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  _buildChevronAction(() {Navigator.pushNamed(context, "/profile/watchlist", arguments: externalUser);}, displayUser?.watchlist.length ?? 0),
                ],
              ),
            ),
            if (!userProvider.isLoadingUser && displayUser?.watchlist.isNotEmpty == true)
            ListSeries(series: displayUser?.watchlist.sublist(0, displayUser.watchlist.length > 10 ? 10 : displayUser.watchlist.length) ?? []),
            if (!userProvider.isLoadingUser && displayUser?.reviews.isNotEmpty == true)
            LineSeparator(),
            if (!userProvider.isLoadingUser && displayUser?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resenhas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildChevronAction(() {Navigator.pushNamed(context, "/profile/reviews", arguments: externalUser);}, displayUser?.reviews.length ?? 0),
                ],
              ),
            ),
            if (!userProvider.isLoadingUser && displayUser?.reviews.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: userProvider.isLoadingUser
                ? ListReviewsSkeleton(itemCount: 3)
                : Column(
                    spacing: 12,
                    children: [
                      for (var review in displayUser?.reviews.sublist(0, displayUser.reviews.length > 3 ? 3 : displayUser.reviews.length) ?? [])
                        ReviewCard(review: review),
                    ],
                  ),
            ),
            if (!userProvider.isLoadingUser && !userProvider.isLoadingUser &&
            (
              externalUser == false ||
              (externalUser == true && displayUser?.lists.isNotEmpty == true)
            ))
            LineSeparator(),
            if (!userProvider.isLoadingUser && !userProvider.isLoadingUser &&
            (
              externalUser == false ||
              (externalUser == true && displayUser?.lists.isNotEmpty == true)
            ))
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Listas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (
                    !userProvider.isLoadingUser &&
                    externalUser == false &&
                    (displayUser?.lists.isEmpty ?? true)
                  )
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Material(
                      color: Color.fromARGB(89, 120, 120, 128),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/list/create',
                          );
                        },
                        child: Center(
                          child: Icon(Icons.add, color: colorTertiary, size: 24),
                        ),
                      ),
                    ),
                  ),
                  if (
                    !userProvider.isLoadingUser &&
                    displayUser?.lists.isNotEmpty == true
                  ) _buildChevronAction(() {Navigator.pushNamed(context, "/profile/lists", arguments: externalUser);}, displayUser?.lists.length ?? 0),
                ],
              ),
            ),
            if (userProvider.isLoadingUser)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ListReviewsSkeleton(itemCount: 5,)
              ),
            if (!userProvider.isLoadingUser && displayUser?.lists.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                spacing: 12,
                children: [
                  for (var list in displayUser?.lists.sublist(0, displayUser.lists.length > 3 ? 3 : displayUser.lists.length) ?? [])
                    ListPopularCard(list: list),
                ],
              ),
            ),
            LineSeparator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 8.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Diário de Séries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _buildChevronAction(() {Navigator.pushNamed(context, "/profile/diary", arguments: displayUser?.id);}),
                ],
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      )
    );
  }
}
