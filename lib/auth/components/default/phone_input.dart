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
  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.controller.currentLabels['phoneVerification'] ?? "전화번호",
            style: const TextStyle(
              color: Color(0xFF353535),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 45,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white,  // 배경색을 흰색으로 변경
                border: Border.all(color: const Color(0xFFF2F3F7)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ValueListenableBuilder<String>(
                valueListenable: widget.controller.dialCodeNotifier,
                builder: (context, currentDialCode, _) {
                  final selectedDialCode = widget.controller.getSelectedDialCode();

                  return PopupMenuButton<CountryDialCode>(
                    initialValue: selectedDialCode,
                    onSelected: (CountryDialCode code) {
                      widget.controller.setDialCode(code);
                    },
                    color: Colors.white,  // 드롭다운 메뉴 배경색을 흰색으로 설정
                    itemBuilder: (context) {
                      return PhoneController.dialCodes.map((code) {
                        return PopupMenuItem(
                          value: code,
                          child: Row(
                            children: [
                              Text(code.flag),
                              const SizedBox(width: 8),
                              Text(code.dialCode),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(selectedDialCode.flag),
                                const SizedBox(width: 4),
                                Text(selectedDialCode.dialCode, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                height: 45,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1, color: Color(0xFFF2F3F7)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Center(
                  child: TextField(
                    controller: widget.controller.phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 12),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: "01012345678",
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      isDense: true,
                    ),
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