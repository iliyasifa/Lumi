import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentId;
  final String uid;
  final String username;
  final String userProfileUrl;
  final String text;
  final DateTime datePublished;
  final List likes;

  const Comment({
    required this.commentId,
    required this.uid,
    required this.username,
    required this.userProfileUrl,
    required this.text,
    required this.datePublished,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'commentId': commentId,
        'uid': uid,
        'username': username,
        'userProfileUrl': userProfileUrl,
        'text': text,
        'datePublished': datePublished,
        'likes': likes,
      };

  static Comment fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;

    return Comment(
      commentId: data['commentId'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      userProfileUrl: data['userProfileUrl'] ?? '',
      text: data['text'] ?? '',
      datePublished: (data['datePublished'] as Timestamp).toDate(),
      likes: data['likes'] ?? [],
    );
  }
}
