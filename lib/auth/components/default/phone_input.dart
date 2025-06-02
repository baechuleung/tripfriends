import 'package:flutter/material.dart';
import '../../controller/default/phone_controller.dart';
import '../../../main.dart';

class PhoneInput extends StatefulWidget {
  final PhoneController controller;

  const PhoneInput({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _showDropdown() {
    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _removeOverlay();
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 반투명 배경
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // 화면 정중앙에 드롭다운 배치
            Center(
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shrinkWrap: true,
                      itemCount: PhoneController.dialCodes.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE4E4E4),
                        indent: 0,
                        endIndent: 0,
                      ),
                      itemBuilder: (context, index) {
                        final code = PhoneController.dialCodes[index];
                        final isSelected = code.dialCode == widget.controller.dialCodeNotifier.value;

                        return InkWell(
                          onTap: () {
                            widget.controller.setDialCode(code);
                            _removeOverlay();
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            color: isSelected ? const Color(0xFFE8F2FF) : null,
                            child: Row(
                              children: [
                                Text(
                                  code.flag,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  code.dialCode,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF353535),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.controller.currentLabels['phoneVerification'] ?? "전화번호",
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 국가 코드 드롭다운
            GestureDetector(
              onTap: _toggleDropdown,
              child: Container(
                width: 120,
                height: 50,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFFE4E4E4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ValueListenableBuilder<String>(
                  valueListenable: widget.controller.dialCodeNotifier,
                  builder: (context, currentDialCode, _) {
                    final selectedDialCode = widget.controller.getSelectedDialCode();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(selectedDialCode.flag),
                              const SizedBox(width: 4),
                              Text(
                                selectedDialCode.dialCode,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF353535),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: const Color(0xFF999999),
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // 전화번호 입력 필드
            Expanded(
              child: Container(
                height: 50,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE4E4E4),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: TextField(
                  controller: widget.controller.phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF353535),
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: "01012345678",
                    hintStyle: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    isDense: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}