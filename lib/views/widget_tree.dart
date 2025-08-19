import 'package:bet_u/data/notifiers.dart';
import 'package:bet_u/views/pages/challenge_page.dart';

import 'package:bet_u/views/pages/community_tab/community_page.dart';
import 'package:bet_u/views/pages/home_page.dart';
import 'package:bet_u/views/pages/profile_page.dart';
import 'package:bet_u/views/pages/settings_page.dart';
import 'package:bet_u/views/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';

List<Widget> pages = [
  HomePage(),
  ChallengePage(),
  CommunityPage(),
  ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bet U'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SettingsPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
