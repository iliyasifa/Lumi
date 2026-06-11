import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String uid;
  final String username;
  final String userProfileUrl;
  final String description;
  final String postUrl;
  final DateTime datePublished;
  final List likes;
  final String location;

  const Post({
    required this.postId,
    required this.uid,
    required this.username,
    required this.userProfileUrl,
    required this.description,
    required this.postUrl,
    required this.datePublished,
    required this.likes,
    this.location = '',
  });

  Map<String, dynamic> toJson() => {
        'postId': postId,
        'uid': uid,
        'username': username,
        'userProfileUrl': userProfileUrl,
        'description': description,
        'postUrl': postUrl,
        'datePublished': datePublished,
        'likes': likes,
        'location': location,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;

    return Post(
      postId: data['postId'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? '',
      userProfileUrl: data['userProfileUrl'] ?? '',
      description: data['description'] ?? '',
      postUrl: data['postUrl'] ?? '',
      datePublished: (data['datePublished'] as Timestamp).toDate(),
      likes: data['likes'] ?? [],
      location: data['location'] ?? '',
    );
  }
}
