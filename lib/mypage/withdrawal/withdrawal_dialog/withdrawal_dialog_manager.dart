import 'package:flutter/material.dart';
import '../../../services/translation_service.dart';
import 'withdrawal_dialog.dart';

class WithdrawalDialogManager {
  final BuildContext context;
  final TranslationService? translationService;

  WithdrawalDialogManager({
    required this.context,
    this.translationService,
  }) {
    // 초기화 시 번역도 초기화
    _initTranslation();
  }

  // 번역 초기화 메서드
  Future<void> _initTranslation() async {
    if (translationService != null) {
      await translationService!.init();
    }
  }

  // 출금 성공 다이얼로그 표시
  void showSuccessDialog({Function()? afterConfirm}) {
    WithdrawalDialog.showSuccessDialog(
      context: context,
      title: translationService?.get('withdrawal_request', '출금 신청') ?? '출금 신청',
      content: translationService?.get('withdrawal_success', '출금 요청은 관리자가 수동으로 처리하며, 2~3일 소요됩니다.') ??
          '출금 요청은 관리자가 수동으로 처리하며, 2~3일 소요됩니다.',
      buttonText: translationService?.get('confirm', '확인') ?? '확인',
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
    WithdrawalDialog.showErrorDialog(
      context: context,
      title: translationService?.get('error', '오류') ?? '오류',
      content: translationService?.get(errorKey, defaultErrorMessage) ?? defaultErrorMessage,
      buttonText: translationService?.get('confirm', '확인') ?? '확인',
      onConfirm: afterConfirm,
    );
  }

  // 출금 확인 다이얼로그 표시
  void showConfirmDialog({
    required Function() onConfirm,
    Function()? onCancel,
  }) {
    WithdrawalDialog.showConfirmWithdrawalDialog(
      context: context,
      title: translationService?.get('confirm_withdrawal', '출금 확인') ?? '출금 확인',
      content: translationService?.get('confirm_withdrawal_message', '정말로 출금 신청을 하시겠습니까?') ??
          '정말로 출금 신청을 하시겠습니까?',
      confirmText: translationService?.get('withdraw', '출금하기') ?? '출금하기',
      cancelText: translationService?.get('cancel', '취소') ?? '취소',
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
    WithdrawalDialog.showLoadingDialog(
      context: context,
      message: translationService?.get('processing', '처리 중...') ?? '처리 중...',
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