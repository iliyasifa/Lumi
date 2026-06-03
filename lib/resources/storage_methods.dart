import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage({
    required String childName,
    required Uint8List file,
    required bool isPost,
  }) async {
    try {
      final String uid = _auth.currentUser!.uid;
      Reference ref = _storage.ref().child(childName).child(uid);
      UploadTask uploadTask = ref.putData(file);

      TaskSnapshot snap = await uploadTask;

      final String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}
