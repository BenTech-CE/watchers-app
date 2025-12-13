import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/series_card.dart';

class ProfileListsPage extends StatefulWidget {
  const ProfileListsPage({super.key});

  @override
  State<ProfileListsPage> createState() => _ProfileListsPageState();
}

class _ProfileListsPageState extends State<ProfileListsPage> {
  FullUserModel? user;
  bool externalUser = false;

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();

      final externalUser = ModalRoute.of(context)!.settings.arguments as bool;

      if (externalUser) {
        setState(() {
          user = userProvider.selectedUser;
          this.externalUser = true;
        });
      } else {
        setState(() {
          user = userProvider.currentUser;
          this.externalUser = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final displayUser = externalUser ? user : userProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text("Listas", style: AppTextStyles.bodyLarge.copyWith(fontSize: 22, fontWeight: FontWeight.w600),),
        actions: [
          if (!externalUser) Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
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
              )
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 23,);
          },
          itemCount: displayUser?.lists.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            return ListPopularCard(list: displayUser!.lists[index]);
          },
        ),
      ),
    );
  }
}