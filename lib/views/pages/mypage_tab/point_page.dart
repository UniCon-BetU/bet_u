import 'dart:convert';
import 'package:bet_u/utils/point_api.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_participate_page.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_start_page.dart';
import 'package:flutter/material.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/point_option_card_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_result.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_certification_page.dart';
import 'package:flutter/material.dart';
import '../../../models/challenge.dart';
import 'package:bet_u/views/pages/challenge_tab/challenge_participate_page.dart';

import 'package:bet_u/views/widgets/chip_widget.dart';
import 'package:bet_u/views/widgets/long_button_widget.dart';
import '../../../theme/app_colors.dart';

import 'package:bet_u/views/widgets/goal_bubble_widget.dart';
// Toss Payments Flutter SDK
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';

class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  // ── Toss widget ──────────────────────────────────────────────────────────────
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  // ── State ───────────────────────────────────────────────────────────────────
  int userPoints = 0; // 현재 로그인 유저 포인트
  int selectedAmount = 3000;
  int? userId;
  bool _loading = false;

  final List<Map<String, dynamic>> pointOptions = [
    {
      "points": 3000,
      "amount": 3000,
      "bonus": 0,
      "image": "assets/images/point/point_1Lv.png",
    },
    {
      "points": 5000,
      "amount": 5000,
      "bonus": 0,
      "image": "assets/images/point/point_2Lv.png",
    },
    {
      "points": 10000,
      "amount": 9900,
      "bonus": 100,
      "image": "assets/images/point/point_3Lv.png",
      "background": "assets/images/point/background/bg1.png",
    },
    {
      "points": 30000,
      "amount": 29800,
      "bonus": 200,
      "image": "assets/images/point/point_4Lv.png",
      "background": "assets/images/point/background/bg2.png",
    },
    {
      "points": 50000,
      "amount": 49500,
      "bonus": 500,
      "image": "assets/images/point/point_4Lv.png",
      "background": "assets/images/point/background/bg3.png",
    },
    {
      "points": 100000,
      "amount": 99900,
      "bonus": 1000,
      "image": "assets/images/point/point_4Lv.png",
      "background": "assets/images/point/background/bg4.png",
    },
  ];

  @override
  void initState() {
    super.initState();

    // ✅ 토스 위젯 초기화
    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", // 테스트 키
      customerKey: "yi5Sv5mHoX6s5l9kM2wiQ", // 임의의 고객 키
    );

    _initPaymentWidgets();
    _initUser();
  }

  Future<void> _initPaymentWidgets() async {
    // 결제수단 위젯 그리기
    _paymentMethodWidgetControl = await _paymentWidget.renderPaymentMethods(
      selector: 'methods',
      amount: Amount(
        value: selectedAmount,
        currency: Currency.KRW,
        country: "KR",
      ),
      options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
    );

    // 약관 위젯 그리기
    _agreementWidgetControl = await _paymentWidget.renderAgreement(
      selector: 'agreement',
    );
  }

  Future<void> _initUser() async {
    final id = await TokenStorage.getUserId();
    if (id == null) return;
    userId = id;
    await _fetchUserPoints();
  }

  Future<void> _fetchUserPoints() async {
    try {
      final points = await PointApi.fetchUserPoints();
      setState(() => userPoints = points);
    } catch (e) {
      debugPrint('포인트 불러오기 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('포인트 불러오기 실패')));
    }
  }

  Future<void> _payAndSelect(int amt) async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    setState(() => selectedAmount = amt);
    await _paymentMethodWidgetControl?.updateAmount(amount: amt);

    final option = pointOptions.firstWhere((o) => o["amount"] == amt);
    final int bonus = option["bonus"] ?? 0;

    try {
      setState(() => _loading = true);

      // 결제 요청
      final result = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          orderName: '$amt 포인트 구매',
        ),
      );

      final success = result.success;
      final fail = result.fail;

      if (success != null) {
        final paymentKey = success.paymentKey;
        final orderId = success.orderId;

        // 실제 결제된 금액(필드명 방어)
        final paidAmount = success.amount ?? amt;

        final confirmed = await PointApi.confirmCharge(
          paymentKey: paymentKey,
          orderId: orderId,
          amount: paidAmount.toInt(),
        );

        setState(() => userPoints = confirmed.totalPoint);

        if (!mounted) return;

        // 결제 성공 스낵바
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 성공! 현재 포인트: ${confirmed.totalPoint} P')),
        );

        // 결제 완료 후 challenge_start_page로 이동
        Navigator.pop<int>(context, confirmed.totalPoint);
      } else if (fail != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('[${'결제 실패'}')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('알 수 없는 결제 결과입니다.')));
      }
    } catch (e) {
      debugPrint('포인트 충전 실패: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('포인트 충전 실패: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spinner = _loading
        ? const LinearProgressIndicator(minHeight: 2)
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 결제'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: spinner,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── 현재 포인트 표시 바 ───────────────────────────────────────────
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
                      const Positioned(
                        left: 16,
                        child: Text(
                          '현재 포인트',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: 112,
                          width: 112,
                          child: Image.asset(
                            'assets/images/point_icon_x3.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
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

            // ── 결제수단/약관 위젯 표시 영역 ─────────────────────────────────
            // ⚠️ 이 두 위젯이 있어야 결제수단 선택/약관이 실제로 렌더됩니다.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // 결제수단
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: PaymentMethodWidget(
                      paymentWidget: _paymentWidget,
                      selector: 'methods',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 약관
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AgreementWidget(
                      paymentWidget: _paymentWidget,
                      selector: 'agreement',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── 포인트 상품 선택 리스트 ─────────────────────────────────────
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
                        bonus: (option["bonus"] ?? 0) > 0
                            ? option["bonus"]
                            : null,
                        imagePath: option["image"],
                        backgroundImagePath: option["background"],
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

extension on Fail {
  Null get errorMsg => null;
}
