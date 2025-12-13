import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/series_card.dart';

class ProfileReviewsPage extends StatefulWidget {
  const ProfileReviewsPage({super.key});

  @override
  State<ProfileReviewsPage> createState() => _ProfileReviewsPageState();
}

class _ProfileReviewsPageState extends State<ProfileReviewsPage> {
  FullUserModel? user;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();

      final externalUser = ModalRoute.of(context)!.settings.arguments as bool;

      if (externalUser) {
        setState(() {
          user = userProvider.selectedUser;
        });
      } else {
        setState(() {
          user = userProvider.currentUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Resenhas", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 23,);
          },
          itemCount: user?.reviews.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return ReviewCard(review: user!.reviews[index]);
          },
        ),
      ),
    );
  }
}