import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stories = [
      {'name': 'Your Story', 'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150'},
      {'name': 'alex_wander', 'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'},
      {'name': 'sarah_m', 'url': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'},
      {'name': 'mike_travel', 'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'},
      {'name': 'emma_design', 'url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150'},
      {'name': 'john_fit', 'url': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150'},
    ];

    final posts = [
      {
        'username': 'sarah_m',
        'userProfile': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        'location': 'Paris, France',
        'likes': 1243,
        'caption': 'Strolling around the city of lights ✨. #paris #travel',
        'time': '2 hours ago',
        'colors': [const Color(0xFF8A2387), const Color(0xFFE94057)],
      },
      {
        'username': 'alex_wander',
        'userProfile': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        'location': 'Tokyo, Japan',
        'likes': 854,
        'caption': 'Neon nights and city lights 🏮. #tokyo #explore',
        'time': '4 hours ago',
        'colors': [const Color(0xFF1f4068), const Color(0xFF162447)],
      },
      {
        'username': 'mike_travel',
        'userProfile': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        'location': 'Bali, Indonesia',
        'likes': 2341,
        'caption': 'Lost in paradise 🌴. #bali #vacation #vibes',
        'time': '1 day ago',
        'colors': [const Color(0xFF00b4db), const Color(0xFF0083b0)],
      },
    ];

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
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // Stories list
          SizedBox(
            height: 104,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isFirst
                              ? null
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF833AB4),
                                    Color(0xFFFD1D1D),
                                    Color(0xFFF77737),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                          color: isFirst ? Colors.grey.withValues(alpha: 0.2) : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundImage: NetworkImage(stories[index]['url']!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 68,
                        child: Text(
                          stories[index]['name']!,
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
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E1E1E)),

          // Feed posts
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(post['userProfile'] as String),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['username'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  post['location'] as String,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Post content image/card
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: post['colors'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.photo_outlined,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 64,
                        ),
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite_border, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.bookmark_border, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Likes, caption and comments
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${post['likes']} likes',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: '${post['username']} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: post['caption'] as String),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'View all ${(post['likes'] as int) ~/ 5} comments',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            post['time'] as String,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
