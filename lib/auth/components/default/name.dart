import 'package:flutter/material.dart';
import '../../controller/default/name_controller.dart';
import '../../../main.dart';

class Name extends StatefulWidget {
  final NameController controller;

  const Name({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
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
          widget.controller.currentLabels['name']!,
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
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
          child: Center(
            child: TextField(
              controller: widget.controller.nameController,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: widget.controller.currentLabels['name_dec'],
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}