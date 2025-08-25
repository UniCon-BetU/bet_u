import 'package:bet_u/views/pages/login_page.dart';
import 'package:bet_u/views/pages/signup_page.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.yellowGreen,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: FittedBox(
                    child: Image.asset(
                      'assets/images/BETU_mainlogo.png',
                      fit: BoxFit.contain,
                      ),
                  ),
                ),
                SizedBox(height: 48.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LongButtonWidget(
                    text: '시작하기', 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignupPage();
                          },
                        )
                      );
                    },
                    backgroundColor: AppColors.primaryGreen,
                  )
                  // FilledButton(
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) {
                  //           return SignupPage();
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   style: FilledButton.styleFrom(
                  //     minimumSize: Size(double.infinity, 44),
                  //     backgroundColor: AppColors.primaryGreen,
                  //     foregroundColor: Colors.white,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(11),
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     '시작하기',
                  //     style: TextStyle(
                  //       fontSize: 20,
                  //       fontWeight: FontWeight.w600,
                  //       color: Colors.white,
                  //     )),
                  // ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LoginPage();
                          },
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: Size(double.infinity, 40.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      )
                    ),
                    child: Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryGreen,
                      )
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
