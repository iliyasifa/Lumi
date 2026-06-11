import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lumi/view_models/profile/profile_view_model.dart';

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
            onPressed: () => _showProfileOptions(context, isOwnProfile, ref, targetUid),
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

void _showProfileOptions(
  BuildContext context,
  bool isOwnProfile,
  WidgetRef ref,
  String targetUid,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF262626),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwnProfile) ...[
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.white),
                title: const Text('QR Code', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: Colors.white),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text('Copy Profile Link', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.red),
                title: const Text('Report', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Block', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
