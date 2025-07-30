import 'package:bet_u/views/widgets/container_widget.dart';
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
            SizedBox(height: 10.0),
            SizedBox(height: 5.0),
            ContainerWidget(title: "제목", description: '설명입니다'),
          ],
        ),
      ),
    );
  }
}
