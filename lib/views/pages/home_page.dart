import 'package:bet_u/views/pages/community_page.dart';
import 'package:bet_u/views/pages/theme_page.dart';
import 'package:bet_u/views/widgets/container_widget.dart';
import 'package:bet_u/views/widgets/pointbutton_widget.dart';
import 'package:bet_u/views/widgets/themecard_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [PointbuttonWidget(point: 80)],
            ),
            SizedBox(height: 10.0),
            ContainerWidget(title: "BET U", description: '당신에게 베팅하세요!'),
            SizedBox(height: 10.0),
            Text('테마'),
            SizedBox(height: 10.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ThemePage(
                              title: '운동',
                              icon: Icons.directions_run,
                            );
                          },
                        ),
                      );
                    },
                    child: ThemecardWidget(
                      icon: Icons.directions_run,
                      title: '운동',
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ThemePage(title: '일상', icon: Icons.bed);
                          },
                        ),
                      );
                    },
                    child: ThemecardWidget(icon: Icons.bed, title: '일상'),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ThemePage(title: '공부', icon: Icons.book);
                          },
                        ),
                      );
                    },
                    child: ThemecardWidget(icon: Icons.book, title: '공부'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CommunityPage();
                    },
                  ),
                );
              },
              child: ContainerWidget(
                title: "커뮤니티",
                description: '다른 도전자들과 소통해요',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
