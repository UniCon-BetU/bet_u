import 'package:bet_u/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: '홈'),
            NavigationDestination(icon: Icon(Icons.flag), label: '챌린지'),
            NavigationDestination(icon: Icon(Icons.people), label: '커뮤니티'),
            NavigationDestination(icon: Icon(Icons.person), label: '프로필'),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }
}
