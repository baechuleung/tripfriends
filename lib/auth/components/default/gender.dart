import 'package:flutter/material.dart';
import '../../controller/default/gender_controller.dart';
import '../../../main.dart';

class Gender extends StatefulWidget {
  final GenderController controller;

  const Gender({
    super.key,
    required this.controller,
  });

  @override
  State<Gender> createState() => _GenderState();
}

class _GenderState extends State<Gender> {
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
        Text(
          widget.controller.currentLabels['gender']!,
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: widget.controller.genderNotifier,
                builder: (context, selectedGender, _) {
                  return Row(
                    children: [
                      _buildGenderButton(
                        context: context,
                        label: widget.controller.currentLabels['male']!,
                        value: 'male',
                        isSelected: selectedGender == 'male',
                        onTap: () => widget.controller.gender = 'male',
                      ),
                      const SizedBox(width: 8),
                      _buildGenderButton(
                        context: context,
                        label: widget.controller.currentLabels['female']!,
                        value: 'female',
                        isSelected: selectedGender == 'female',
                        onTap: () => widget.controller.gender = 'female',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton({
    required BuildContext context,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF3182F6) : const Color(0xFFD1D1D1),
            ),
            borderRadius: BorderRadius.circular(5),
            color: isSelected ? const Color(0xFFE8F2FF) : Colors.white,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }
}