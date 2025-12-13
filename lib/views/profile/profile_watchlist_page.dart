import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/series_card.dart';

class ProfileWatchlistPage extends StatefulWidget {
  const ProfileWatchlistPage({super.key});

  @override
  State<ProfileWatchlistPage> createState() => _ProfileWatchlistPageState();
}

class _ProfileWatchlistPageState extends State<ProfileWatchlistPage> {
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
        title: Text("Assistir Futuramente", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GridView.builder(
            gridDelegate: 
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 23,
                mainAxisSpacing: 23,
                childAspectRatio: 2 / 3,
              ),
            itemCount: user?.watchlist.length ?? 0,
            itemBuilder: (context, index) {
              final series = user!.watchlist[index];
              return SeriesCard(
                series: series,
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
        ),
      ),
    );
  }
}