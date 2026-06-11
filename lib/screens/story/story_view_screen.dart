import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lumi/resources/firestore_methods.dart';

class StoryViewScreen extends HookWidget {
  final List<Map<String, dynamic>> stories;
  final int initialIndex;

  const StoryViewScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = useState(initialIndex);
    final progressController = useAnimationController(
      duration: const Duration(seconds: 5),
    );

    void nextStory() {
      if (currentIndex.value < stories.length - 1) {
        currentIndex.value++;
      } else {
        Navigator.pop(context);
      }
    }

    void previousStory() {
      if (currentIndex.value > 0) {
        currentIndex.value--;
      }
    }

    useEffect(() {
      progressController.reset();
      progressController.forward();

      // Mark as viewed
      final story = stories[currentIndex.value];
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && story['uid'] != uid) {
        FirestoreMethods().viewStory(story['storyId'], uid);
      }

      void statusListener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          nextStory();
        }
      }

      progressController.addStatusListener(statusListener);
      return () => progressController.removeStatusListener(statusListener);
    }, [currentIndex.value]);

    final story = stories[currentIndex.value];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            previousStory();
          } else {
            nextStory();
          }
        },
        onLongPressStart: (_) => progressController.stop(),
        onLongPressEnd: (_) => progressController.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Story image
            CachedNetworkImage(
              imageUrl: story['mediaUrl'] ?? '',
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade900,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white24,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade900,
                child: const Icon(Icons.error, color: Colors.white24, size: 40),
              ),
            ),

            // Gradient overlay at top
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
            ),

            // Top UI
            SafeArea(
              child: Column(
                children: [
                  // Progress bars
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: List.generate(
                        stories.length,
                        (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: index == currentIndex.value
                                    ? AnimatedBuilder(
                                        animation: progressController,
                                        builder: (context, child) {
                                          return LinearProgressIndicator(
                                            value: progressController.value,
                                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                                            minHeight: 2.5,
                                          );
                                        },
                                      )
                                    : LinearProgressIndicator(
                                        value: index < currentIndex.value ? 1.0 : 0.0,
                                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                        minHeight: 2.5,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // User info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: CachedNetworkImageProvider(
                            story['userProfileUrl'] ?? 'https://i.stack.imgur.com/l60Hf.png',
                          ),
                          backgroundColor: Colors.grey.shade900,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          story['username'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _timeAgo(story['datePublished']),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(dynamic date) {
    if (date == null) return '';
    DateTime dateTime;
    if (date is DateTime) {
      dateTime = date;
    } else {
      try {
        dateTime = (date as dynamic).toDate();
      } catch (_) {
        return '';
      }
    }

    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
