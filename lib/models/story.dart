import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String storyId;
  final String uid;
  final String username;
  final String userProfileUrl;
  final String mediaUrl;
  final DateTime datePublished;
  final List viewers;

  const Story({
    required this.storyId,
    required this.uid,
    required this.username,
    required this.userProfileUrl,
    required this.mediaUrl,
    required this.datePublished,
    this.viewers = const [],
  });

  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'uid': uid,
        'username': username,
        'userProfileUrl': userProfileUrl,
        'mediaUrl': mediaUrl,
        'datePublished': datePublished,
        'viewers': viewers,
      };

  static Story fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;

    return Story(
      storyId: data['storyId'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      userProfileUrl: data['userProfileUrl'] ?? '',
      mediaUrl: data['mediaUrl'] ?? '',
      datePublished: (data['datePublished'] as Timestamp).toDate(),
      viewers: data['viewers'] ?? [],
    );
  }

  /// Check if story is still active (within 24 hours)
  bool get isActive => DateTime.now().difference(datePublished).inHours < 24;
}
