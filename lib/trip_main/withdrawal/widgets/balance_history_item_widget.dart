import 'package:flutter/material.dart';
import '../controller/balance_history_controller.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart'; // currentCountryCode

class BalanceHistoryItemWidget extends StatefulWidget {
  final Map<String, dynamic> historyItem;
  final BalanceHistoryController controller;

  const BalanceHistoryItemWidget({
    Key? key,
    required this.historyItem,
    required this.controller,
  }) : super(key: key);

  @override
  State<BalanceHistoryItemWidget> createState() => _BalanceHistoryItemWidgetState();
}

class _BalanceHistoryItemWidgetState extends State<BalanceHistoryItemWidget> {
  @override
  Widget build(BuildContext context) {
    final String type = widget.historyItem['type'] ?? 'unknown';
    final bool isWithdrawal = type == 'withdrawal';
    final String withdrawalStatus = widget.historyItem['status'] ?? 'pending'; // 출금인 경우 상태 확인

    // 사용자의 기본 통화 기호 사용
    final String currencySymbol = widget.controller.getUserCurrencySymbol();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.controller.formatDate(widget.historyItem['created_at']),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                isWithdrawal
                    ? widget.controller.getWithdrawalStatusText(withdrawalStatus)
                    : widget.controller.getTypeText(type),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isWithdrawal
                      ? widget.controller.getWithdrawalStatusColor(withdrawalStatus)
                      : (type == 'earn' ? const Color(0xFF237AFF) : widget.controller.getTypeColor(type)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getTransactionTitle(type),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    // 적립은 '+', 출금/사용은 '-' 기호 추가
                    '${_getAmountPrefix(type)}$currencySymbol ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(type),
                    ),
                  ),
                  Text(
                    widget.controller.formatAmount(widget.historyItem['amount']),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getAmountColor(type),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 설명이 있는 경우 표시 (description 표시 안함)
          /*
          if (widget.historyItem['description'] != null && widget.historyItem['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.historyItem['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          */

          // 출금인 경우 계좌 정보 표시
          if (isWithdrawal && widget.historyItem['account_number'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '${widget.historyItem['account_holder'] ?? ''} | ${_maskAccountNumber(widget.historyItem['account_number'] ?? '')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],

          // 은행 정보 (출금인 경우)
          if (isWithdrawal && widget.historyItem['bank_name'] != null && widget.historyItem['bank_name'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${widget.historyItem['bank_name']}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],

          // SWIFT 코드 (국제 송금인 경우)
          if (isWithdrawal && widget.historyItem['swift_code'] != null && widget.historyItem['swift_code'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'SWIFT: ${widget.historyItem['swift_code']}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],

          // 수취인 주소 (국제 송금인 경우)
          if (isWithdrawal && widget.historyItem['receiver_address'] != null && widget.historyItem['receiver_address'].toString().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '주소: ${_shortenAddress(widget.historyItem['receiver_address'])}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // 거래 유형별 제목 가져오기
  String _getTransactionTitle(String type) {
    final language = currentCountryCode.toUpperCase();

    // 데이터에 거래 제목이 있으면 사용
    if (widget.historyItem['title'] != null && widget.historyItem['title'].toString().isNotEmpty) {
      return widget.historyItem['title'];
    }

    // source가 있으면 source에 맞는 번역 텍스트 사용
    if (widget.historyItem['source'] != null && widget.historyItem['source'].toString().isNotEmpty) {
      final String source = widget.historyItem['source'].toString();
      return widget.controller.getSourceText(source);
    }

    // 없으면 유형별 기본값 사용
    switch (type) {
      case 'earn':
        return MypageTranslations.getTranslation('earn_points', language);
      case 'use':
        return MypageTranslations.getTranslation('use_points', language);
      case 'withdrawal':
        return MypageTranslations.getTranslation('withdraw_points', language);
      default:
        return MypageTranslations.getTranslation('points_transaction', language);
    }
  }

// 금액 표시를 위한 기호 (+ 또는 -)
  String _getAmountPrefix(String type) {
    if (type == 'withdrawal') {
      return '-';
    } else {
      return '+';
    }
  }

  // 금액 색상
  Color _getAmountColor(String type) {
    if (type == 'earn') {
      return const Color(0xFF237AFF);
    } else if (type == 'withdrawal') {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 8) {
      return accountNumber;
    }

    final visible = accountNumber.substring(0, 4);
    final masked = '*' * (accountNumber.length - 4);

    return '$visible$masked';
  }

  String _shortenAddress(String address) {
    if (address.length <= 20) {
      return address;
    }
    return '${address.substring(0, 20)}...';
  }
}