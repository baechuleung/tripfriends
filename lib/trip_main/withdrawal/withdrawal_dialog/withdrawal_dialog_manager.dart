import 'package:flutter/material.dart';
import '../../../translations/mypage_translations.dart';
import '../../../main.dart'; // currentCountryCode
import 'withdrawal_dialog.dart';

class WithdrawalDialogManager {
  final BuildContext context;

  WithdrawalDialogManager({required this.context});

  // 출금 성공 다이얼로그 표시
  void showSuccessDialog({Function()? afterConfirm}) {
    final language = currentCountryCode.toUpperCase();

    WithdrawalDialog.showSuccessDialog(
      context: context,
      title: MypageTranslations.getTranslation('withdrawal_request', language),
      content: MypageTranslations.getTranslation('withdrawal_success', language),
      buttonText: MypageTranslations.getTranslation('confirm', language),
      autoDismiss: true,
      onConfirm: afterConfirm,
    );
  }

  // 출금 에러 다이얼로그 표시
  void showErrorDialog({
    required String errorKey,
    required String defaultErrorMessage,
    Function()? afterConfirm,
  }) {
    final language = currentCountryCode.toUpperCase();

    WithdrawalDialog.showErrorDialog(
      context: context,
      title: MypageTranslations.getTranslation('error', language),
      content: MypageTranslations.getTranslation(errorKey, language),
      buttonText: MypageTranslations.getTranslation('confirm', language),
      onConfirm: afterConfirm,
    );
  }

  // 출금 확인 다이얼로그 표시
  void showConfirmDialog({
    required Function() onConfirm,
    Function()? onCancel,
  }) {
    final language = currentCountryCode.toUpperCase();

    WithdrawalDialog.showConfirmWithdrawalDialog(
      context: context,
      title: MypageTranslations.getTranslation('confirm_withdrawal', language),
      content: MypageTranslations.getTranslation('confirm_withdrawal_message', language),
      confirmText: MypageTranslations.getTranslation('withdraw', language),
      cancelText: MypageTranslations.getTranslation('cancel', language),
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  // 은행정보 오류 다이얼로그 표시
  void showBankInfoErrorDialog() {
    showErrorDialog(
      errorKey: 'bank_info_required',
      defaultErrorMessage: '출금 정보를 모두 입력해주세요.',
    );
  }

  // 출금 처리 중 로딩 다이얼로그 표시
  void showLoadingDialog() {
    final language = currentCountryCode.toUpperCase();

    WithdrawalDialog.showLoadingDialog(
      context: context,
      message: MypageTranslations.getTranslation('processing', language),
    );
  }

  // 로딩 다이얼로그 닫기
  void hideLoadingDialog() {
    WithdrawalDialog.hideLoadingDialog(context);
  }

  // 에러 메시지에 따른 적절한 다이얼로그 표시
  void showErrorMessageDialog(String errorCode) {
    String errorKey;
    String defaultErrorMessage;

    switch (errorCode) {
      case 'user_not_found':
        errorKey = 'user_not_found';
        defaultErrorMessage = '사용자 정보를 찾을 수 없습니다.';
        break;
      case 'below_minimum':
        errorKey = 'below_minimum';
        defaultErrorMessage = '최소 출금 금액은 100,000원 이상입니다.';
        break;
      case 'no_bank_info':
        errorKey = 'no_bank_info';
        defaultErrorMessage = '출금 정보를 먼저 입력해주세요.';
        break;
      default:
        errorKey = 'withdrawal_error';
        defaultErrorMessage = '출금 신청 중 오류가 발생했습니다.';
    }

    showErrorDialog(
      errorKey: errorKey,
      defaultErrorMessage: defaultErrorMessage,
    );
  }
}