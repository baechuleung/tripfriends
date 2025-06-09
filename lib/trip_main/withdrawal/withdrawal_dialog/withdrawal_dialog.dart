import 'package:flutter/material.dart';
import 'withdrawal_dialog_widget.dart';

/// 출금 다이얼로그의 기능 부분을 담당하는 클래스
class WithdrawalDialog {
  /// 출금 성공 다이얼로그 표시
  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    Function()? onConfirm,
    bool? autoDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialogWidget.buildSuccessDialog(
        context: context,
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: () {
          // 다이얼로그 닫기
          Navigator.of(context).pop();

          // 확인 콜백 실행
          if (onConfirm != null) {
            onConfirm();
          }

          // 자동 닫기 옵션이 활성화되었다면 이전 화면으로 돌아가기
          if (autoDismiss == true) {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  /// 출금 에러 다이얼로그 표시
  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    Function()? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialogWidget.buildErrorDialog(
        context: context,
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: () {
          // 다이얼로그 닫기
          Navigator.of(context).pop();

          // 확인 콜백 실행
          if (onConfirm != null) {
            onConfirm();
          }
        },
      ),
    );
  }

  /// 출금 확인 다이얼로그 표시
  static void showConfirmWithdrawalDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
    required Function() onConfirm,
    Function()? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialogWidget.buildConfirmDialog(
        context: context,
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirmPressed: () {
          // 다이얼로그 닫기
          Navigator.of(context).pop();

          // 확인 콜백 실행
          onConfirm();
        },
        onCancelPressed: () {
          // 다이얼로그 닫기
          Navigator.of(context).pop();

          // 취소 콜백 실행
          if (onCancel != null) {
            onCancel();
          }
        },
      ),
    );
  }

  /// 출금 처리 중 로딩 다이얼로그 표시
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WithdrawalDialogWidget.buildLoadingDialog(
        context: context,
        message: message,
      ),
    );
  }

  /// 로딩 다이얼로그 닫기
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}