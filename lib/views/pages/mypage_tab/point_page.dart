import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bet_u/utils/point_api.dart';
import 'package:bet_u/utils/point_store.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:bet_u/utils/token_util.dart';
import 'package:bet_u/views/widgets/point_option_card_widget.dart';
// import 들은 기존대로

class PointPage extends StatefulWidget {
  const PointPage({super.key});
  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  // Toss Payments
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

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
    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm", // 테스트 키
      customerKey: "yi5Sv5mHoX6s5l9kM2wiQ", // 고객 식별 키
    );
    _initPaymentWidgets();
    _initUserAndPoints();
  }

  Future<void> _initUserAndPoints() async {
    try {
      userId = await TokenStorage.getUserId();
      final token = (await TokenStorage.getToken())?.trim();
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다. (토큰 없음)')));
        return;
      }

      await PointStore.instance.ensureLoaded();
      // OK
    } catch (e) {
      if (!mounted) return;
      // e 안에 status/body가 들어가서 원인 파악 쉬움
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('포인트 불러오기 실패: $e')));
    }
  }

  Future<void> _initPaymentWidgets() async {
    _paymentMethodWidgetControl = await _paymentWidget.renderPaymentMethods(
      selector: 'methods',
      amount: Amount(
        value: selectedAmount,
        currency: Currency.KRW,
        country: "KR",
      ),
      options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
    );
    _agreementWidgetControl = await _paymentWidget.renderAgreement(
      selector: 'agreement',
    );
  }

  Future<void> _payAndSelect(int amt) async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final status = await _agreementWidgetControl?.getAgreementStatus();
    if (status != null && status.agreedRequiredTerms != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('필수 약관에 동의해 주세요')));
      return;
    }

    setState(() => selectedAmount = amt);
    await _paymentMethodWidgetControl?.updateAmount(amount: amt);

    try {
      setState(() => _loading = true);

      // 1) 토스 결제창 호출
      final result = await _paymentWidget.requestPayment(
        paymentInfo: PaymentInfo(
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          orderName: '$amt 포인트 구매',
        ),
      );

      // 2) 결과 분기
      final success = result.success;
      final fail = result.fail;

      if (success != null) {
        final paymentKey = success.paymentKey;
        final orderId = success.orderId;
        final paidAmount = success.amount;

        // 3) 서버 승인 + 포인트 적립 (API 유틸 그대로 사용)
        final confirmed = await PointApi.confirmCharge(
          paymentKey: paymentKey,
          orderId: orderId,
          amount: paidAmount.toInt(),
        );

        if (!mounted) return;

        // 4) 전역 포인트 갱신(서버 권위)
        PointStore.instance.setFromServer(confirmed.totalPoint);

        // 5) 알림 + 부모로 최신 포인트 반환(선택)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('결제 성공! 현재 포인트: ${confirmed.totalPoint} P')),
        );
        Navigator.pop<int>(context, confirmed.totalPoint);
      } else if (fail != null) {
        if (!mounted) return;

        final Map<String, dynamic> map = jsonDecode(jsonEncode(fail));

        final code = map['errorCode']?.toString() ?? '';
        final msg =
            map['message']?.toString() ??
            map['errorMsg']?.toString() ??
            map['error']?.toString() ??
            '';

        final text = msg.isNotEmpty ? '[$code] $msg' : '결제 실패';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(text)));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('알 수 없는 결제 결과입니다.')));
      }
    } catch (e) {
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
            // 현재 포인트 바
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
                        child: ValueListenableBuilder<int>(
                          valueListenable: PointStore.instance.points,
                          builder: (_, p, _) => Text(
                            '$p P',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 결제수단/약관
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
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

            // 상품 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pointOptions.length,
                itemBuilder: (context, index) {
                  final option = pointOptions[index];
                  return Column(
                    children: [
                      PointOptionCard(
                        points: option["points"] as int,
                        amount: option["amount"] as int,
                        bonus: (option["bonus"] ?? 0) as int > 0
                            ? option["bonus"] as int
                            : null,
                        imagePath: option["image"] as String,
                        backgroundImagePath: option["background"] as String?,
                        onTap: () => _payAndSelect(option["amount"] as int),
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
