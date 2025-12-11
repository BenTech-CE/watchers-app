import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/reviews/reviews_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/review_card.dart';

class TrendingLists extends StatefulWidget {
  const TrendingLists({super.key});

  @override
  State<TrendingLists> createState() => _TrendingListsState();
}

class _TrendingListsState extends State<TrendingLists> {
  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Listas populares", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 23,);
          },
          itemCount: listsProvider.trendingLists.length,
          itemBuilder: (BuildContext context, int index) {
            return ListPopularCard(list: listsProvider.trendingLists[index]);
          },
        ),
      ),
    );
  }
}