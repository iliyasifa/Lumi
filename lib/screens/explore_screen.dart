import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_flutter_clone/screens/profile_screen.dart';

class ExploreScreen extends HookWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    final isSearching = useState(false);
    final searchQuery = useState('');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: SizedBox(
          height: 44,
          child: TextFormField(
            controller: searchController,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (value) {
              searchQuery.value = value.trim();
              isSearching.value = value.trim().isNotEmpty;
            },
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 14),
              prefixIcon: Icon(Icons.search,
                  color: Colors.white.withValues(alpha: 0.5), size: 20),
              suffixIcon: isSearching.value
                  ? IconButton(
                      icon: Icon(Icons.close,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 18),
                      onPressed: () {
                        searchController.clear();
                        searchQuery.value = '';
                        isSearching.value = false;
                        FocusScope.of(context).unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF0095F6), width: 1.2),
              ),
            ),
          ),
        ),
      ),
      body: isSearching.value
          ? _buildSearchResults(searchQuery.value, context)
          : _buildExploreGrid(),
    );
  }

  /// Search results — queries users by username
  Widget _buildSearchResults(String query, BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No users found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: CachedNetworkImageProvider(
                  data['photoUrl'] ??
                      'https://i.stack.imgur.com/l60Hf.png',
                ),
                backgroundColor: Colors.grey.shade900,
              ),
              title: Text(
                data['username'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                data['bio'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(uid: data['uid']),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Explore grid — shows real posts
  Widget _buildExploreGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('datePublished', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.explore_outlined,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nothing to explore yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Posts from the community will appear here.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.custom(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(2),
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: [
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(2, 1),
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(1, 1),
            ],
          ),
          childrenDelegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= snapshot.data!.docs.length) return null;
              final data = snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;
              final likes = data['likes'] as List? ?? [];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfileScreen(uid: data['uid']),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: data['postUrl'] ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade900,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade900,
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Subtle overlay with likes
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 12,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${likes.length}',
                            style: TextStyle(
                              color:
                                  Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            childCount: snapshot.data!.docs.length,
          ),
        );
      },
    );
  }
}
