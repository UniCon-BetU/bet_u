import 'package:flutter/material.dart';
import 'package:bet_u/views/widgets/point_option_card_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:bet_u/models/challenge.dart';
import 'package:bet_u/data/global_challenges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PointPage(),
    );
  }
}

class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  int selectedAmount = 3000; // 초기값 없음 → null

  // 카드 옵션 리스트
  final List<Map<String, dynamic>> pointOptions = [
    {
      "points": 3000,
      "amount": 3000,
      "bonus": 0,
      "image": "images/point/point_1Lv.png",
    },
    {
      "points": 5000,
      "amount": 5000,
      "bonus": 0,
      "image": "images/point/point_2Lv.png",
    },
    {
      "points": 10000,
      "amount": 9900,
      "bonus": 100,
      "image": "images/point/point_3Lv.png",
      "background": "images/point/background/bg1.png",
    },
    {
      "points": 30000,
      "amount": 29800,
      "bonus": 200,
      "image": "images/point/point_4Lv.png",
      "background": "images/point/background/bg2.png",
    },
    {
      "points": 50000,
      "amount": 49500,
      "bonus": 500,
      "image": "images/point/point_4Lv.png",
      "background": "images/point/background/bg3.png",
    },
    {
      "points": 100000,
      "amount": 99900,
      "bonus": 1000,
      "image": "images/point/point_4Lv.png",
      "background": "images/point/background/bg4.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "yi5Sv5mHoX6s5l9kM2wiQ",
    );

    _paymentWidget
        .renderPaymentMethods(
          selector: 'methods',
          amount: Amount(
            value: selectedAmount,
            currency: Currency.KRW,
            country: "KR",
          ),
          options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
        )
        .then((control) => _paymentMethodWidgetControl = control);

    _paymentWidget
        .renderAgreement(selector: 'agreement')
        .then((control) => _agreementWidgetControl = control);
  }

  void _payAndSelect(int amt) async {
    setState(() => selectedAmount = amt); // 카드 선택 표시
    await _paymentMethodWidgetControl?.updateAmount(amount: amt);

    // 선택한 카드 정보 가져오기 (보너스 포함)
    final option = pointOptions.firstWhere((o) => o["amount"] == amt);
    final int bonus = option["bonus"] ?? 0;

    // 결제 요청
    final result = await _paymentWidget.requestPayment(
      paymentInfo: PaymentInfo(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        orderName: '$amt 포인트 구매',
      ),
    );

    if (!mounted) return;

    if (result.success != null) {
      // 결제 성공 시 포인트 + 보너스 업데이트
      setState(() {
        userPoints += amt + bonus;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('결제 성공!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('결제 실패!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 결제'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 현재 포인트 배너
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 50,
                  color: const Color(0xFF1BAB0F),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 좌측 텍스트
                      Positioned(
                        left: 16,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '현재 포인트',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 가운데 이미지
                      Center(
                        child: SizedBox(
                          height: 112,
                          width: 112,
                          child: Image.asset(
                            'images/point_icon_x3.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // 우측 포인트 숫자
                      Positioned(
                        right: 16,
                        child: Text(
                          '$userPoints P',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 포인트 선택 카드
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pointOptions.length,
                itemBuilder: (context, index) {
                  final option = pointOptions[index];
                  return Column(
                    children: [
                      PointOptionCard(
                        points: option["points"],
                        amount: option["amount"],
                        bonus: option["bonus"] > 0 ? option["bonus"] : null,
                        imagePath: option["image"],
                        backgroundImagePath: option["background"], // 배경 이미지 추가
                        onTap: () => _payAndSelect(option["amount"]),
                        isSelected: selectedAmount == option["amount"],
                      ),

                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
