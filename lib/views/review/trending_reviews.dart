import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/review_card.dart';

class TrendingReviews extends StatefulWidget {
  const TrendingReviews({super.key});

  @override
  State<TrendingReviews> createState() => _TrendingReviewsState();
}

class _TrendingReviewsState extends State<TrendingReviews> {
  @override
  Widget build(BuildContext context) {
    final reviewProvider = context.watch<ReviewsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Resenhas populares", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 12,);
          },
          itemCount: reviewProvider.trendingReviews.length,
          itemBuilder: (BuildContext context, int index) {
            return ReviewCard(review: reviewProvider.trendingReviews[index]);
          },
        ),
      ),
    );
  }
}