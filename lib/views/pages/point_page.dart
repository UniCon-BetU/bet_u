import 'package:flutter/material.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_info.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/agreement.dart';
import 'package:tosspayments_widget_sdk_flutter/widgets/payment_method.dart';

class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  late PaymentWidget _paymentWidget;
  PaymentMethodWidgetControl? _paymentMethodWidgetControl;
  AgreementWidgetControl? _agreementWidgetControl;

  @override
  void initState() {
    super.initState();

    _paymentWidget = PaymentWidget(
      clientKey: "test_gck_docs_Ovk5rk1EwkEbP0W43n07xlzm",
      customerKey: "yi5Sv5mHoX6s5l9kM2wiQ",
      // 결제위젯에 브랜드페이 추가하기
      // paymentWidgetOptions: PaymentWidgetOptions(brandPayOption: BrandPayOption("리다이렉트 URL")) // Access Token 발급에 사용되는 리다이렉트 URL
    );

    _paymentWidget
        .renderPaymentMethods(
          selector: 'methods',
          amount: Amount(value: 300, currency: Currency.KRW, country: "KR"),
          options: RenderPaymentMethodsOptions(variantKey: "DEFAULT"),
        )
        .then((control) {
          _paymentMethodWidgetControl = control;
        });

    _paymentWidget.renderAgreement(selector: 'agreement').then((control) {
      _agreementWidgetControl = control;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포인트 결제'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context); // 🔹 [뒤로가기 동작]
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  PaymentMethodWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'methods',
                  ),
                  AgreementWidget(
                    paymentWidget: _paymentWidget,
                    selector: 'agreement',
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final paymentResult = await _paymentWidget.requestPayment(
                        paymentInfo: const PaymentInfo(
                          orderId: 'Tusz7S3PE5gpTNjACHOqR',
                          orderName: '토스 티셔츠 외 2건',
                        ),
                      );
                      if (paymentResult.success != null) {
                        // 결제 성공 처리
                      } else if (paymentResult.fail != null) {
                        // 결제 실패 처리
                      }
                    },
                    child: const Text('결제하기'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final selectedPaymentMethod =
                          await _paymentMethodWidgetControl
                              ?.getSelectedPaymentMethod();
                      print(
                        '${selectedPaymentMethod?.method} ${selectedPaymentMethod?.easyPay?.provider ?? ''}',
                      );
                    },
                    child: const Text('선택한 결제수단 출력'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final agreementStatus = await _agreementWidgetControl
                          ?.getAgreementStatus();
                      print('${agreementStatus?.agreedRequiredTerms}');
                    },
                    child: const Text('약관 동의 상태 출력'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _paymentMethodWidgetControl?.updateAmount(
                        amount: 300,
                      );
                      print('결제 금액이 300원으로 변경되었습니다.');
                    },
                    child: const Text('결제 금액 변경'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
