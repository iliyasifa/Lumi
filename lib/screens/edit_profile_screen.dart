import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter_clone/resources/firestore_methods.dart';
import 'package:instagram_flutter_clone/utils/utils.dart';

class EditProfileScreen extends HookConsumerWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController(text: userData['username'] ?? '');
    final bioController = useTextEditingController(text: userData['bio'] ?? '');
    final newProfileImage = useState<Uint8List?>(null);
    final isLoading = useState(false);

    void selectImage() async {
      Uint8List? file = await pickImage(ImageSource.gallery);
      if (file != null) {
        newProfileImage.value = file;
      }
    }

    void saveProfile() async {
      isLoading.value = true;

      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      String res = await FirestoreMethods().updateProfile(
        uid: uid,
        username: usernameController.text.trim(),
        bio: bioController.text.trim(),
        profileImage: newProfileImage.value,
      );

      isLoading.value = false;

      if (context.mounted) {
        if (res == 'success') {
          showSnackBar(
            content: 'Profile updated!',
            ctx: context,
            isError: false,
          );
          Navigator.pop(context);
        } else {
          showSnackBar(content: res, ctx: context);
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: isLoading.value ? null : saveProfile,
            child: Text(
              'Done',
              style: TextStyle(
                color: isLoading.value ? Colors.blue.withValues(alpha: 0.4) : const Color(0xFF0095F6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            if (isLoading.value)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  color: Color(0xFF0095F6),
                  backgroundColor: Colors.black,
                ),
              ),

            // Profile image
            GestureDetector(
              onTap: selectImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey.shade900,
                    backgroundImage: newProfileImage.value != null
                        ? MemoryImage(newProfileImage.value!)
                        : CachedNetworkImageProvider(
                            userData['photoUrl'] ?? 'https://i.stack.imgur.com/l60Hf.png',
                          ) as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0095F6),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: selectImage,
              child: const Text(
                'Change profile photo',
                style: TextStyle(
                  color: Color(0xFF0095F6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Username
            _buildField('Username', usernameController),
            const SizedBox(height: 16),

            // Bio
            _buildField('Bio', bioController, maxLines: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0095F6), width: 1.2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
