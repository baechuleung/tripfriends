import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/balance_controller.dart';
import '../../withdrawal/withdrawal_page.dart';
import '../balance_history_page.dart';
import '../../../main.dart';  // currentCountryCode 접근용

class BalanceCardWidget extends StatefulWidget {
  final BalanceController controller;

  const BalanceCardWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<BalanceCardWidget> createState() => _BalanceCardWidgetState();
}

class _BalanceCardWidgetState extends State<BalanceCardWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (!widget.controller.isInitialized) {
      await widget.controller.init();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    // 디버그 정보 출력
    debugPrint('BalanceCardWidget 초기화 완료');
    debugPrint('현재 국가 코드: $currentCountryCode');
    debugPrint('컨트롤러 언어 코드: ${widget.controller.getCurrentLanguage()}');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 적립금 카드 내용 (헤더 제거됨)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildBalanceCardContent(context),
        ),
      ],
    );
  }

  // 적립금 카드 내용
  Widget _buildBalanceCardContent(BuildContext context) {
    // minimum_withdrawal 번역 준비
    String minimumWithdrawalText = '출금은 {symbol} {amount} 이상 부터 가능합니다.';

    String translatedText = widget.controller.translationService.get(
        'minimum_withdrawal',
        minimumWithdrawalText
    );

    minimumWithdrawalText = translatedText
        .replaceAll('{symbol}', widget.controller.currencySymbol)
        .replaceAll('{amount}', widget.controller.withdrawalLimit);

    debugPrint('번역된 최소 출금 안내: $minimumWithdrawalText');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: widget.controller.getUserStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${widget.controller.currencySymbol} ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                );
              }

              if (snapshot.hasError) {
                debugPrint('스트림 에러: ${snapshot.error}');
                return Text(
                  '${widget.controller.currencySymbol} ${widget.controller.getFormattedPoint()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                );
              }

              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null) {
                  final point = userData['point']?.toString() ?? '0';
                  final formattedPoint = widget.controller.formatPoint(point);

                  debugPrint('사용자 포인트: $point, 형식화된 포인트: $formattedPoint');

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.controller.currencySymbol} ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        formattedPoint,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                }
              }

              // 기본값 표시
              debugPrint('기본 포인트 표시: ${widget.controller.getFormattedPoint()}');
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${widget.controller.currencySymbol} ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.controller.getFormattedPoint(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            minimumWithdrawalText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceHistoryButton(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWithdrawButton(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHistoryButton(BuildContext context) {
    String balanceHistoryText = widget.controller.translationService.get('balance_history', '적립금내역');
    debugPrint('번역된 적립금내역 텍스트: $balanceHistoryText');

    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BalanceHistoryPage(
                translationService: widget.controller.getTranslationService,
              ),
            ),
          ).then((_) {
            // 내역 화면에서 돌아오면 데이터 갱신
            widget.controller.init();
            if (mounted) {
              setState(() {}); // UI 갱신
            }
          });
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          balanceHistoryText,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    String withdrawText = widget.controller.translationService.get('withdraw', '출금하기');
    debugPrint('번역된 출금하기 텍스트: $withdrawText');

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WithdrawalPage(
                translationService: widget.controller.getTranslationService,
              ),
            ),
          ).then((_) {
            // 출금 화면에서 돌아오면 데이터 갱신
            widget.controller.init();
            if (mounted) {
              setState(() {}); // UI 갱신
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4169E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          withdrawText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}