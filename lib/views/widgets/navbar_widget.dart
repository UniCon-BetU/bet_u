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
              Icon(icon, size: 24, color: color),
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
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorShape: const CircleBorder(),
                
                
                overlayColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.pressed)) {
                    return AppColors.lighterGreen;
                  } if (states.contains(WidgetState.hovered)) {
                    return AppColors.lightGray.withValues(alpha: 0.25);
                  }
                  return Colors.transparent;
                }),

                backgroundColor: Colors.white,
                indicatorColor: Colors.transparent,
              ), 
              child: NavigationBar(
                height: 72,
                selectedIndex: selectedPage,
                onDestinationSelected: (int value) {
                  selectedPageNotifier.value = value;
                },

                destinations: [
                  _dest(index: 0, selectedIndex: selectedPage, icon: Icons.home_rounded, label: '홈'),
                  _dest(index: 1, selectedIndex: selectedPage, icon: Icons.stars, label: '챌린지'),
                  _dest(index: 2, selectedIndex: selectedPage, icon: Icons.forum_rounded, label: '소셜'),
                  _dest(index: 3, selectedIndex: selectedPage, icon: Icons.person_pin_circle_sharp, label: '마이페이지'),
                ],
              )
            ),
          );
        },
      );
    }
  }
