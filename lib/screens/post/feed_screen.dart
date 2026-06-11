import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumi/resources/firestore_methods.dart';
import 'package:lumi/screens/activity/activity_screen.dart';
import 'package:lumi/screens/messages/inbox_screen.dart';
import 'package:lumi/screens/story/story_view_screen.dart';
import 'package:lumi/utils/utils.dart';
import 'package:lumi/view_models/auth/auth_view_model.dart';
import 'package:lumi/view_models/notifications/notifications_view_model.dart';
import 'package:lumi/widgets/post_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authViewModelProvider).user;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF0095F6)],
          ).createShader(bounds),
          child: const Text(
            'Lumi',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount.toString()),
              backgroundColor: const Color(0xFFE50914),
              child: const Icon(Icons.favorite_border, color: Colors.white),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActivityScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InboxScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ─── STORIES BAR ──────────────────────────
          _StoriesBar(currentUser: currentUser),
          const Divider(height: 1, color: Color(0xFF1E1E1E)),

          // ─── FEED POSTS ───────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('datePublished', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.only(top: 100),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white24,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Share your first photo to get started!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return PostCard(snap: data);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── STORIES BAR ─────────────────────────────────────────

class _StoriesBar extends StatelessWidget {
  final dynamic currentUser;

  const _StoriesBar({this.currentUser});

  @override
  Widget build(BuildContext context) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));

    return SizedBox(
      height: 104,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stories')
            .where('datePublished', isGreaterThan: cutoff)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Group stories by user
          Map<String, List<Map<String, dynamic>>> userStories = {};
          bool currentUserHasStory = false;

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final uid = data['uid'] as String;
              if (!userStories.containsKey(uid)) {
                userStories[uid] = [];
              }
              userStories[uid]!.add(data);

              if (uid == FirebaseAuth.instance.currentUser?.uid) {
                currentUserHasStory = true;
              }
            }
          }

          // Build story items: "Your Story" first, then other users
          List<Widget> storyWidgets = [];

          // Your Story
          storyWidgets.add(
            _StoryAvatar(
              name: 'Your Story',
              imageUrl: currentUser?.photoUrl ?? 'https://i.stack.imgur.com/l60Hf.png',
              hasStory: currentUserHasStory,
              isYourStory: true,
              onTap: () {
                if (currentUserHasStory) {
                  final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                  final stories = userStories[currentUid] ?? [];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewScreen(stories: stories),
                    ),
                  );
                } else {
                  _addStory(context);
                }
              },
            ),
          );

          // Other users' stories
          final currentUid = FirebaseAuth.instance.currentUser?.uid;
          for (var entry in userStories.entries) {
            if (entry.key == currentUid) continue;
            final firstStory = entry.value.first;
            storyWidgets.add(
              _StoryAvatar(
                name: firstStory['username'] ?? '',
                imageUrl: firstStory['userProfileUrl'] ?? 'https://i.stack.imgur.com/l60Hf.png',
                hasStory: true,
                isYourStory: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryViewScreen(stories: entry.value),
                    ),
                  );
                },
              ),
            );
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: storyWidgets,
          );
        },
      ),
    );
  }

  void _addStory(BuildContext context) async {
    final Uint8List? file = await pickImage(ImageSource.gallery);
    if (file == null) return;

    if (currentUser == null) return;

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    String res = await FirestoreMethods().uploadStory(
      file,
      uid,
      currentUser!.username,
      currentUser!.photoUrl,
    );

    if (context.mounted) {
      if (res == 'success') {
        showSnackBar(
          content: 'Story uploaded!',
          ctx: context,
          isError: false,
        );
      } else {
        showSnackBar(content: res, ctx: context);
      }
    }
  }
}

class _StoryAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool hasStory;
  final bool isYourStory;
  final VoidCallback onTap;

  const _StoryAvatar({
    required this.name,
    required this.imageUrl,
    required this.hasStory,
    required this.isYourStory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStory
                        ? const LinearGradient(
                            colors: [
                              Color(0xFF833AB4),
                              Color(0xFFFD1D1D),
                              Color(0xFFF77737),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          )
                        : null,
                    color: !hasStory ? Colors.grey.withValues(alpha: 0.2) : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: CircleAvatar(
                      radius: 26,
                      backgroundImage: CachedNetworkImageProvider(imageUrl),
                      backgroundColor: Colors.grey.shade900,
                    ),
                  ),
                ),
                if (isYourStory && !hasStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0095F6),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 68,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
