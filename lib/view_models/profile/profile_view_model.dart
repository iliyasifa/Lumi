import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileState {
  final Map<String, dynamic> userData;
  final int postLen;
  final int followers;
  final int following;
  final bool isFollowing;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.userData = const {},
    this.postLen = 0,
    this.followers = 0,
    this.following = 0,
    this.isFollowing = false,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Map<String, dynamic>? userData,
    int? postLen,
    int? followers,
    int? following,
    bool? isFollowing,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      userData: userData ?? this.userData,
      postLen: postLen ?? this.postLen,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      isFollowing: isFollowing ?? this.isFollowing,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends FamilyNotifier<ProfileState, String> {
  @override
  ProfileState build(String arg) {
    Future.microtask(() => fetchProfileData());
    return const ProfileState(isLoading: true);
  }

  Future<void> fetchProfileData() async {
    state = state.copyWith(isLoading: true);
    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final targetUid = arg.isEmpty ? (currentUid ?? '') : arg;

      if (targetUid.isEmpty) {
        state = state.copyWith(isLoading: false, error: 'User not logged in');
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUid)
          .get();

      final postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: targetUid)
          .get();

      if (snap.exists && snap.data() != null) {
        final data = snap.data()!;
        final followersList = data['followers'] as List? ?? [];
        final followingList = data['following'] as List? ?? [];

        state = ProfileState(
          userData: data,
          postLen: postSnap.docs.length,
          followers: followersList.length,
          following: followingList.length,
          isFollowing: followersList.contains(currentUid),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'User does not exist');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final profileViewModelProvider =
    NotifierProvider.family<ProfileNotifier, ProfileState, String>(() {
  return ProfileNotifier();
});
