import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/user_diary_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_series_skeleton.dart';
import 'package:watchers/widgets/series_card.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage>  with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<UserDiaryModel> userDiary = [];

  @override
  void initState(){
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      dynamic userId = ModalRoute.of(context)!.settings.arguments;

      final userProvider = context.read<UserProvider>();

      final result = await userProvider.getUserDiaryById(userId);

      if (userProvider.errorMessage == null && mounted) {
        setState(() {
          userDiary = result;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Diário de Séries", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: userProvider.isLoadingGetDiary ? GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 30,
                childAspectRatio: 2 / 3,
              ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return SerieSkeletonCard(
                animation: _animation,
              );
            },
          ) : GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
            itemCount: userDiary.length,
            itemBuilder: (context, index) {
              final series = userDiary[index];
              return LayoutBuilder(
                builder: (context, constraints) {
                  final imageWidth = constraints.maxWidth;
                  final imageHeight = imageWidth * 1.5; // aspect ratio 2:3
                  final starSize = imageWidth / 6;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: imageWidth,
                        height: imageHeight,
                        child: ImageCard(
                          animation: _animation,
                          url: series.posterUrl,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/series/detail',
                              arguments: series.id.toString(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ..._buildStarRating(series.stars ?? 0, starSize),
                          if (series.liked != null && series.liked == true) Icon(
                            Icons.favorite,
                            color: const Color(0xFFCC4A4A),
                            size: starSize,
                          ),
                        ],
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Helper para construir a lista de ícones de estrela
  List<Widget> _buildStarRating(double rating, double size) {
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      Color color = Colors.amber;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      } else {
        continue;
      }
      stars.add(Icon(iconData, color: color, size: size));
    }
    return stars;
  }
}