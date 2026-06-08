import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExploreScreen extends HookWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = useTextEditingController();
    
    final categories = [
      'Trending',
      'Shop',
      'Travel',
      'Aesthetics',
      'Food',
      'Music',
      'Fitness',
      'Gaming',
      'Style',
    ];

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
            decoration: InputDecoration(
              hintText: 'Search visual gallery...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5), size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0095F6), width: 1.2),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Category Strip
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isFirst = index == 0;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? const Color(0xFF0095F6)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isFirst
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: TextStyle(
                        color: isFirst ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Explore Grid Feed
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 0.8,
              ),
              itemCount: 21, // 21 simulated explore items
              itemBuilder: (context, index) {
                // We can use different gradients to simulate photos/videos
                final gradientColors = [
                  [const Color(0xFF1F1C2C), const Color(0xFF928DAB)],
                  [const Color(0xFF4CA1AF), const Color(0xFF2C3E50)],
                  [const Color(0xFF2C3E50), const Color(0xFFFD746C)],
                  [const Color(0xFF283048), const Color(0xFF859398)],
                  [const Color(0xFF121212), const Color(0xFF2F2F2F)],
                  [const Color(0xFF0F2027), const Color(0xFF203A43)],
                  [const Color(0xFF1D976C), const Color(0xFF93F9B9)],
                ];

                final colors = gradientColors[index % gradientColors.length];
                final isVideo = index % 4 == 0;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (isVideo)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite_border,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(index + 1) * 34}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
