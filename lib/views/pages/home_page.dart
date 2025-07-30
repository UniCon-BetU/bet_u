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
            ContainerWidget(title: "제목", description: '설명입니다'),
            SizedBox(height: 10.0),
            Text('테마'),
            SizedBox(height: 10.0),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ThemecardWidget(icon: Icons.directions_run, title: '헬스 케어'),
                  SizedBox(width: 12),
                  ThemecardWidget(icon: Icons.bed, title: '일상'),
                  SizedBox(width: 12),
                  ThemecardWidget(icon: Icons.book, title: '공부'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
