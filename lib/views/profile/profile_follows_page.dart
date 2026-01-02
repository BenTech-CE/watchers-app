import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/auth/profile_model.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/utils/number.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/card_skeleton.dart';

class ProfileFollowsPage extends StatefulWidget {
  const ProfileFollowsPage({super.key});

  @override
  State<ProfileFollowsPage> createState() => _ProfileFollowsPageState();
}

class _ProfileFollowsPageState extends State<ProfileFollowsPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  String displayName = "";
  String userId = "";
  int followingCount = 0;
  int followerCount = 0;

  List<ProfileModel> followers = [];
  List<ProfileModel> following = [];

  late AnimationController _animationController;
  late Animation<double> _animation;

  void followUnfollowUser(ProfileModel data) async {
    final userProvider = context.read<UserProvider>();

    if (userProvider.currentUser == null) return;

    final isFollowing = data.isFollowing;
    final userId = data.id;

    if (following.where((user) => user.id == userId).isNotEmpty) {
      following.where((user) => user.id == userId).first.isFollowing = !isFollowing;
    }
    
    if (followers.where((user) => user.id == userId).isNotEmpty) {
      followers.where((user) => user.id == userId).first.isFollowing = !isFollowing;
    }
    //data.isFollowing = !isFollowing;

    if (userProvider.currentUser!.id == this.userId) {
      followingCount += isFollowing ? -1 : 1;
    }
    userProvider.currentUser!.followingCount += isFollowing ? -1 : 1;

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

      if (following.where((user) => user.id == userId).isNotEmpty) {
        following.where((user) => user.id == userId).first.isFollowing = isFollowing;
      }
      
      if (followers.where((user) => user.id == userId).isNotEmpty) {
        followers.where((user) => user.id == userId).first.isFollowing = isFollowing;
      }

      if (userProvider.currentUser!.id == this.userId) {
        followingCount += isFollowing ? -1 : 1;
      }
      userProvider.currentUser!.followingCount += isFollowing ? -1 : 1;
      setState(() {});
    }
  }

  @override
  void initState(){
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      final uid = args['userId'] as String;

      setState(() {
        displayName = args['displayName'] ?? "";
        followingCount = args['followingCount'] ?? 0;
        followerCount = args['followerCount'] ?? 0;
        userId = uid;
        final initialTab = args['initialTab'] ?? 0;
        _tabController.index = initialTab;
      });

      final UserProvider userProvider = context.read<UserProvider>();

      userProvider.getUserFollowers(uid).then((fetchedFollowers) {
        setState(() {
          followers = fetchedFollowers ?? [];
        });
      });

      userProvider.getUserFollowing(uid).then((fetchedFollowing) {
        setState(() {
          following = fetchedFollowing ?? [];
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141414),
        centerTitle: true,
        title: Text(displayName, style: AppTextStyles.bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: selectedNavBarItemColor,
          labelColor: Colors.white,
          labelStyle: AppTextStyles.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelColor: unselectedNavBarItemColor,
          unselectedLabelStyle: AppTextStyles.bodyLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: [
            Tab(text: "${followerCount.toCompactString()} Seguidores"),
            Tab(text: "${followingCount.toCompactString()} Seguindo"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            userProvider.isLoadingFollowers ?
              ListView.builder(itemBuilder: (context, index) {
                return ListTile(
                  title: ShimmerShape(animation: _animation, width: 100, height: 20, borderRadius: 4),
                  leading: ShimmerShape(animation: _animation, width: 40, height: 40, borderRadius: 999)
                );
              }, itemCount: 10,)
             : ListView.builder(itemBuilder: (context, index) {
              final user = followers[index];

              return ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/profile', arguments: user.id);
                },
                title: Text(user.fullName ?? "@${user.username}", style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),),
                trailing: userProvider.currentUser?.id != user.id ? SizedBox(
                  width: 105,
                  height: 30,
                  child: Button(
                    label: user.isFollowing == true ? "Seguindo" : "Seguir", 
                    onPressed: () {
                      followUnfollowUser(user);
                    },
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    variant: user.isFollowing == true ? ButtonVariant.secondary : ButtonVariant.primary,
                    trailingIcon: Iconify(user.isFollowing == true ? Mdi.user_check_outline : Mdi.user_plus_outline, size: 20, color: tColorPrimary)
                  ),
                ) : null,
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }, itemCount: followers.length),
            userProvider.isLoadingFollowing ?
              ListView.builder(itemBuilder: (context, index) {
                return ListTile(
                  title: ShimmerShape(animation: _animation, width: 100, height: 20, borderRadius: 4),
                  leading: ShimmerShape(animation: _animation, width: 40, height: 40, borderRadius: 999)
                );
              }, itemCount: 10,)
             : ListView.builder(itemBuilder: (context, index) {
              final user = following[index];

              return ListTile(
                onTap: () {
                  Navigator.pushNamed(context, '/profile', arguments: user.id);
                },
                title: Text(user.fullName ?? "@${user.username}", style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),),
                trailing: SizedBox(
                  width: 105,
                  height: 30,
                  child: Button(
                    label: user.isFollowing == true ? "Seguindo" : "Seguir", 
                    onPressed: () {
                      followUnfollowUser(user);
                    },
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    variant: user.isFollowing == true ? ButtonVariant.secondary : ButtonVariant.primary,
                    trailingIcon: Iconify(user.isFollowing == true ? Mdi.user_check_outline : Mdi.user_plus_outline, size: 20, color: tColorPrimary)
                  ),
                ),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }, itemCount: following.length),
          ],
        ),
      )
    );
  }
}