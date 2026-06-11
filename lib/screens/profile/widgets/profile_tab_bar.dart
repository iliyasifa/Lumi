import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const ProfileTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.grid_on,
                color: selectedTab == 0
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                size: 22),
            onPressed: () => onTabChanged(0),
          ),
          IconButton(
            icon: Icon(Icons.video_library_outlined,
                color: selectedTab == 1
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                size: 22),
            onPressed: () => onTabChanged(1),
          ),
          IconButton(
            icon: Icon(Icons.account_box_outlined,
                color: selectedTab == 2
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
                size: 22),
            onPressed: () => onTabChanged(2),
          ),
        ],
      ),
    );
  }
}
