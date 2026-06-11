import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/view_models/profile/profile_view_model.dart';

import 'widgets/profile_header.dart';
import 'widgets/profile_tab_bar.dart';
import 'widgets/profile_posts_grid.dart';

class ProfileScreen extends HookConsumerWidget {
  final String? uid;
  const ProfileScreen({super.key, this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targetUid = uid ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    final profileState = ref.watch(profileViewModelProvider(targetUid));
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isOwnProfile = uid == null || uid == currentUid;
    final selectedTab = useState(0);

    if (profileState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (profileState.error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error: ${profileState.error}',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      );
    }

    final userData = profileState.userData;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          userData['username'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ProfileHeader(
              userData: userData,
              profileState: profileState,
              isOwnProfile: isOwnProfile,
              currentUid: currentUid,
              targetUid: targetUid,
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E1E)),
          
          ProfileTabBar(
            selectedTab: selectedTab.value,
            onTabChanged: (index) => selectedTab.value = index,
          ),
          
          const Divider(height: 1, color: Color(0xFF1E1E1E)),

          if (selectedTab.value == 0)
            ProfilePostsGrid(
              targetUid: targetUid,
              isOwnProfile: isOwnProfile,
            )
          else if (selectedTab.value == 1)
            const Padding(
              padding: EdgeInsets.only(top: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.video_library_outlined, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('No Reels Yet',
                        style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else if (selectedTab.value == 2)
            const Padding(
              padding: EdgeInsets.only(top: 64),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.account_box_outlined, color: Colors.white24, size: 64),
                    SizedBox(height: 16),
                    Text('No Photos of You',
                        style: TextStyle(
                            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
