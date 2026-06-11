import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lumi/utils/global_variables.dart';

class MobileScreenLayout extends HookConsumerWidget {
  const MobileScreenLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final page = useState(0);

    void navigationTapped(int tappedPage) {
      pageController.jumpToPage(tappedPage);
    }

    void onPageChanged(int changedPage) {
      page.value = changedPage;
    }

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: homeScreenItems,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          currentIndex: page.value,
          onTap: navigationTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                page.value == 0 ? Icons.home : Icons.home_outlined,
                color: page.value == 0 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                size: 26,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                page.value == 1 ? Icons.search : Icons.search_outlined,
                color: page.value == 1 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                size: 26,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                page.value == 2 ? Icons.add_circle : Icons.add_circle_outline,
                color: page.value == 2 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                size: 26,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                page.value == 3 ? Icons.favorite : Icons.favorite_border,
                color: page.value == 3 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                size: 26,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                page.value == 4 ? Icons.person : Icons.person_outline,
                color: page.value == 4 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                size: 26,
              ),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
