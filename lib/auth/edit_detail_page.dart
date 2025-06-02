// edit_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controller/detail/edit_detail_controller.dart';
import 'components/detail/languages.dart';
import 'components/detail/referrer_code_input.dart';
import 'components/detail/introduction_input.dart';
import 'controller/detail/register_detail_controller.dart';
import '../services/translation_service.dart';

// EditDetailController를 직접 참조하는 커스텀 ReferrerCodeInput
class CustomReferrerCodeInput extends StatelessWidget {
  final EditDetailController controller;
  final bool isEditMode;

  const CustomReferrerCodeInput({
    Key? key,
    required this.controller,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 원래 ReferrerCodeInput을 래핑하면서 EditDetailController를 직접 전달
    return ReferrerCodeInput(
      controller: _createAdapter(),
      isEditMode: isEditMode,
    );
  }

  // 임시 어댑터 생성
  RegisterDetailController _createAdapter() {
    return RegisterDetailControllerAdapter(controller);
  }
}

// RegisterDetailController 어댑터
class RegisterDetailControllerAdapter extends RegisterDetailController {
  final EditDetailController controller;

  RegisterDetailControllerAdapter(this.controller) : super(uid: controller.uid);

  @override
  TextEditingController get introductionController => controller.introductionController;

  @override
  TextEditingController get referrerCodeController => controller.referrerCodeController;

  @override
  ValueNotifier<List<String>> get selectedLanguagesNotifier => controller.selectedLanguagesNotifier;

  @override
  ValueNotifier<String?> get referrerCodeErrorNotifier => controller.referrerCodeErrorNotifier;

  @override
  ValueNotifier<String?> get referrerCodeSuccessNotifier => controller.referrerCodeSuccessNotifier;

  @override
  ValueNotifier<bool> get isCheckingReferrerCode => controller.isCheckingReferrerCode;

  @override
  ValueNotifier<String> get currencySymbolNotifier => controller.currencySymbolNotifier;

  @override
  ValueNotifier<String> get currencyCodeNotifier => controller.currencyCodeNotifier;

  // 추천인 정보 노티파이어 추가 접근자
  ValueNotifier<Map<String, String>> get referrerInfoNotifier => controller.referrerInfoNotifier;

  // 기존 추천인 정보가 있는지 확인하는 메서드 추가
  bool get hasExistingReferrer {
    return controller.referrerInfoNotifier.value.isNotEmpty;
  }

  @override
  Future<bool> validateReferrerCode(String code) {
    return controller.validateReferrerCode(code);
  }

  @override
  void updateValidationState() {
    controller.updateValidationState();
  }

  // 중요: 편집 컨트롤러에 대한 참조 제공
  EditDetailController get editController => controller;
}

class EditDetailPage extends StatefulWidget {
  final String uid;

  const EditDetailPage({
    super.key,
    required this.uid,
  });

  @override
  _EditDetailPageState createState() => _EditDetailPageState();
}

class _EditDetailPageState extends State<EditDetailPage> {
  late final EditDetailController _controller;
  late final RegisterDetailController _controllerAdapter;
  final TranslationService _translationService = TranslationService();
  bool isLoading = false;
  bool isDataLoaded = false;

  Map<String, String> currentLabels = {
    "edit": "정보수정",
    "save": "저장하기",
    "referrer_info": "추천인 정보",
  };

  @override
  void initState() {
    super.initState();
    print('🏁 EditDetailPage initState 시작');

    _controller = EditDetailController(
      uid: widget.uid,
      onDataLoaded: _onDataLoaded,
    );

    // 어댑터 생성
    _controllerAdapter = RegisterDetailControllerAdapter(_controller);

    _controller.isSavingNotifier.addListener(_updateLoadingState);
    _controller.isValidNotifier.addListener(_checkButtonState);
    _controller.isDataLoadedNotifier.addListener(_updateDataLoadedState);

    // 데이터 로드
    _initTranslations();

    // 기존 데이터 로드 (비동기 작업이므로 이후 UI가 업데이트됨)
    _controller.loadExistingData();

    print('✅ EditDetailPage initState 완료');
  }

  Future<void> _initTranslations() async {
    try {
      await _translationService.init();
      setState(() {
        currentLabels["edit"] = _translationService.get("edit", "정보수정");
        currentLabels["save"] = _translationService.get("save", "저장하기");
        currentLabels["referrer_info"] = _translationService.get("referrer_info", "추천인 정보");
      });
      print('✅ 번역 데이터 로드 완료 - EditDetailPage: $currentLabels');
    } catch (e) {
      debugPrint('Translation initialization error: $e');
    }
  }

  void _onDataLoaded() {
    if (mounted) {
      setState(() {
        isDataLoaded = true;
        print('🔄 데이터 로드 완료 - UI 업데이트');
      });
    }
  }

  void _updateDataLoadedState() {
    if (mounted) {
      setState(() {
        isDataLoaded = _controller.isDataLoadedNotifier.value;
        print('🔄 데이터 로드 상태 업데이트: $isDataLoaded');
      });
    }
  }

  void _updateLoadingState() {
    if (mounted) {
      setState(() {
        isLoading = _controller.isSavingNotifier.value;
        print('🔄 로딩 상태 업데이트: $isLoading');
      });
    }
  }

  void _checkButtonState() {
    if (mounted) {
      setState(() {
        print('🔘 버튼 상태 업데이트: ${_controller.isValidNotifier.value}');
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 EditDetailPage 빌드 시작 - 데이터 로드됨: $isDataLoaded, 버튼 활성화: ${_controller.isValidNotifier.value}');

    return Stack(
      children: [
        GestureDetector(
          onTap: _dismissKeyboard,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                currentLabels['edit'] ?? '정보 수정',
                style: const TextStyle(
                  color: Color(0xFF353535),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: isDataLoaded
                ? _buildFormContent()
                : const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF3182F6),
              ),
            ),
          ),
        ),
        if (isLoading)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 언어 선택 위젯
            Languages(controller: _controllerAdapter),
            const SizedBox(height: 16),

            // 가격 슬라이더 위젯 삭제 - 이제 국가 코드에 따라 자동으로 설정됨

            // 자기소개 입력 위젯
            IntroductionInput(controller: _controllerAdapter),
            const SizedBox(height: 16),

            // 추천인 코드 입력 위젯
            CustomReferrerCodeInput(
              controller: _controller,
              isEditMode: true,
            ),
            const SizedBox(height: 32),

            // 저장 버튼
            ValueListenableBuilder<bool>(
              valueListenable: _controller.isValidNotifier,
              builder: (context, isValid, _) {
                print('🔘 버튼 상태 빌더: $isValid');
                return ValueListenableBuilder<bool>(
                  valueListenable: _controller.isSavingNotifier,
                  builder: (context, isSaving, _) {
                    final buttonEnabled = isValid && !isSaving;
                    print('🔘 버튼 최종 활성화 상태: $buttonEnabled');

                    return SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: buttonEnabled ? _handleSaveButton : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3182F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor: const Color(0xFFE5E5E5),
                        ),
                        child: isSaving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          currentLabels['save'] ?? "저장하기",
                          style: TextStyle(
                            color: isValid ? Colors.white : const Color(0xFF999999),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveButton() async {
    if (!mounted) return;
    try {
      print('💾 저장 버튼 클릭');
      setState(() {
        isLoading = true;
      });

      await _controller.saveDetailChanges(context);
      print('✅ 상세 정보 수정이 완료되었습니다.');
    } catch (e) {
      print('❌ 수정 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }

      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    print('🏁 EditDetailPage dispose 호출');
    _controller.isSavingNotifier.removeListener(_updateLoadingState);
    _controller.isValidNotifier.removeListener(_checkButtonState);
    _controller.isDataLoadedNotifier.removeListener(_updateDataLoadedState);
    _controller.dispose();
    super.dispose();
  }
}