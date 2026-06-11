import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumi/models/user.dart' as model;
import 'package:lumi/resources/storage_methods.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firebaseFirestore.collection('users').doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  /// [checkEmailExists] checks if an email is already in use
  Future<bool> checkEmailExists(String email) async {
    try {
      final QuerySnapshot result = await _firebaseFirestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// [signUpUser] method used to sign up user
  Future<String> signUpUser({
    required String email,
    required String passWord,
    required String userName,
    required String bio,
    required Uint8List file,
  }) async {
    String res = 'Some error occured';
    try {
      if (email.isNotEmpty &&
          passWord.isNotEmpty &&
          bio.isNotEmpty &&
          userName.isNotEmpty &&
          file.isNotEmpty) {
        /// register the user
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: passWord.trim(),
        );

        final String photoUrl = await StorageMethods().uploadImageToStorage(
          childName: 'profilePics',
          file: file,
          isPost: false,
        );

        model.User user = model.User(
          username: userName,
          uid: userCredential.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          photoUrl: photoUrl,
        );

        /// save user detail in firestore database
        await _firebaseFirestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(user.toJson());

        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = err.message ?? 'This email is badly formatted';
      } else if (err.code == 'email-already-in-use') {
        res = 'This email is already in use';
      } else if (err.code == 'weak-password') {
        res = err.message ?? 'The password should be atleast 6 characters';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  /// [loginUser] method used to login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = err.message ?? 'User not found';
      } else if (err.code == 'wrong-password') {
        res = err.message ?? 'Wrong password';
      } else if (err.code == 'invalid-credential') {
        res = err.message ?? 'Invalid email or password';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  /// [signInWithGoogle] method used to sign in with Google
  Future<String> signInWithGoogle() async {
    String res = "Some error occurred";
    try {
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return "cancelled";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo?.isNewUser == true ||
            !(await _firebaseFirestore.collection('users').doc(user.uid).get())
                .exists) {
          model.User newUser = model.User(
            username: user.displayName ?? 'User',
            uid: user.uid,
            email: user.email ?? '',
            bio: '',
            followers: [],
            following: [],
            photoUrl: user.photoURL ?? 'https://i.stack.imgur.com/l60Hf.png',
          );

          await _firebaseFirestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toJson());
        }
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      res = err.message ?? err.toString();
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
