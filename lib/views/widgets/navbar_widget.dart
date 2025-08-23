  import 'package:bet_u/data/notifiers.dart';
  import 'package:flutter/material.dart';
  import '../../theme/app_colors.dart';

  class NavbarWidget extends StatelessWidget {
    const NavbarWidget({super.key});

    NavigationDestination _dest({
      required int index,
      required int selectedIndex,
      required IconData icon,
      required String label,
    }) {
      final selected = index == selectedIndex;
      final color = selected ? AppColors.primaryGreen : Colors.black;

      return NavigationDestination(
        label: '',
        icon: SizedBox(
          height: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              // const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Theme( // ← ripple까지 싹 제거(필요 없으면 빼도 됨)
              data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: Colors.white,

                  // 선택 인디케이터(그 거지같은 회색 원) 제거
                  indicatorColor: Colors.transparent,
                  indicatorShape: const CircleBorder(),

                  // hover/pressed 오버레이도 제거
                  overlayColor: WidgetStatePropertyAll(Colors.transparent),

                  // 아이콘 상태별 크기/색 (여기 값만 바꿔서 튜닝)
                  iconTheme: WidgetStateProperty.resolveWith((states) {
                    final selected = states.contains(WidgetState.selected);

                    double size = 24;
                    if (states.contains(WidgetState.pressed)) {
                      size = 28;   // 눌렀을 때
                    } else if (states.contains(WidgetState.hovered)) {
                      size = 26;   // 호버
                    } else if (selected) {
                      size = 24;   // 선택 유지
                    }

                    return IconThemeData(
                      size: size,
                      color: selected ? AppColors.primaryGreen : Colors.black,
                    );
                  }),
                ),
                child: NavigationBar(
                  height: 72,
                  // NavigationBar 자체 애니메이션(아이콘 크기 변화가 부드럽게)
                  animationDuration: const Duration(milliseconds: 250),

                  selectedIndex: selectedPage,
                  onDestinationSelected: (value) => selectedPageNotifier.value = value,
                  destinations: [
                    _dest(index: 0, selectedIndex: selectedPage, icon: Icons.home_rounded, label: '홈'),
                    _dest(index: 1, selectedIndex: selectedPage, icon: Icons.stars, label: '챌린지'),
                    _dest(index: 2, selectedIndex: selectedPage, icon: Icons.forum_rounded, label: '소셜'),
                    _dest(index: 3, selectedIndex: selectedPage, icon: Icons.person_pin_circle_sharp, label: '마이페이지'),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }
  }
