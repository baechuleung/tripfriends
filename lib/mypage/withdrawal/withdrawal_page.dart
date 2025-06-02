import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/translation_service.dart';
import 'controller/withdrawal_controller.dart';
import 'withdrawal_dialog/withdrawal_dialog_manager.dart';

class WithdrawalPage extends StatefulWidget {
  final TranslationService? translationService;

  const WithdrawalPage({
    Key? key,
    this.translationService,
  }) : super(key: key);

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  late WithdrawalController _controller;
  late WithdrawalDialogManager _dialogManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WithdrawalController(translationService: widget.translationService);
    _loadData();

    // 출금 금액 입력시 콤마 추가 리스너
    _controller.withdrawalAmountController.addListener(_formatWithdrawalAmount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 다이얼로그 매니저 초기화 (context 필요)
    _dialogManager = WithdrawalDialogManager(
      context: context,
      translationService: widget.translationService,
    );
  }

  @override
  void dispose() {
    _controller.withdrawalAmountController.removeListener(_formatWithdrawalAmount);
    _controller.dispose();
    super.dispose();
  }

  void _formatWithdrawalAmount() {
    final text = _controller.withdrawalAmountController.text;
    final formatted = _controller.formatNumber(text);

    if (text != formatted) {
      _controller.withdrawalAmountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await _controller.init();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _requestWithdrawal() async {
    // 출금 정보가 없는 경우 먼저 저장
    if (!_controller.hasWithdrawalInfo) {
      final success = await _controller.saveBankInfo();
      if (!success) {
        _dialogManager.showBankInfoErrorDialog();
        return;
      }
    }

    // 출금 신청하기 전에 확인 다이얼로그 표시
    _dialogManager.showConfirmDialog(
      onConfirm: _processWithdrawal,
    );
  }

  // 실제 출금 처리 로직
  Future<void> _processWithdrawal() async {
    // 로딩 다이얼로그 표시
    _dialogManager.showLoadingDialog();

    // 출금 신청
    final result = await _controller.requestWithdrawal();

    // 로딩 다이얼로그 닫기
    _dialogManager.hideLoadingDialog();

    if (result == 'success') {
      if (mounted) {
        _dialogManager.showSuccessDialog();
      }
    } else {
      _dialogManager.showErrorMessageDialog(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          widget.translationService?.get('withdraw', '출금하기') ?? '출금하기',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWithdrawalForm(),
            const SizedBox(height: 24),
            _buildWithdrawalButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.translationService?.get('bank_info', '출금 계좌 정보') ?? '출금 계좌 정보',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _controller.bankNameController,
            label: widget.translationService?.get('bank_name', '은행명') ?? '은행명',
            hint: widget.translationService?.get('enter_bank_name', '은행명을 입력해주세요') ?? '은행명을 입력해주세요',
            readOnly: _controller.hasWithdrawalInfo,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _controller.accountNumberController,
            label: widget.translationService?.get('account_number', '계좌번호') ?? '계좌번호',
            hint: widget.translationService?.get('enter_account_number', '계좌번호를 입력해주세요') ?? '계좌번호를 입력해주세요',
            keyboardType: TextInputType.number,
            readOnly: _controller.hasWithdrawalInfo,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _controller.accountHolderController,
            label: widget.translationService?.get('account_holder', '예금주') ?? '예금주',
            hint: widget.translationService?.get('enter_account_holder', '예금주를 입력해주세요') ?? '예금주를 입력해주세요',
            readOnly: _controller.hasWithdrawalInfo,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _controller.receiverAddressController,
            label: widget.translationService?.get('receiver_address', '수취인 주소') ?? '수취인 주소',
            hint: widget.translationService?.get('enter_receiver_address', '수취인 주소를 입력해주세요') ?? '수취인 주소를 입력해주세요',
            readOnly: _controller.hasWithdrawalInfo,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _controller.swiftCodeController,
            label: widget.translationService?.get('swift_code', 'SWIFT 코드') ?? 'SWIFT 코드',
            hint: widget.translationService?.get('enter_swift_code', 'SWIFT 코드를 입력해주세요') ?? 'SWIFT 코드를 입력해주세요',
            readOnly: _controller.hasWithdrawalInfo,
          ),
          if (_controller.hasWithdrawalInfo) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _controller.hasWithdrawalInfo = false;
                  });
                },
                child: Text(
                  widget.translationService?.get('edit_bank_info', '계좌 정보 수정') ?? '계좌 정보 수정',
                  style: const TextStyle(
                    color: Color(0xFF4169E1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(
            widget.translationService?.get('withdrawal_amount', '출금액') ?? '출금액',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '${_controller.currencySymbol} ',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  _controller.getFormattedPoint(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.translationService?.get('minimum_withdrawal_info', '* 최소 출금 금액은 100,000원 이상이어야 합니다.') ?? '* 최소 출금 금액은 100,000원 이상이어야 합니다.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    Widget? prefix,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefix: prefix,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4169E1)),
            ),
            filled: readOnly,
            fillColor: readOnly ? Colors.grey[100] : null,
          ),
          style: TextStyle(
            fontSize: 14,
            color: readOnly ? Colors.grey[600] : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawalButton() {
    // 포인트가 100,000 미만이면 버튼 비활성화
    final withdrawalAmount = int.tryParse(_controller.point.replaceAll(',', '')) ?? 0;
    final isButtonEnabled = withdrawalAmount >= 100000;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? _requestWithdrawal : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4169E1),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.translationService?.get('withdraw', '출금하기') ?? '출금하기',
          style: TextStyle(
            color: isButtonEnabled ? Colors.white : Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}