import 'package:flutter/material.dart';
import '../../controller/default/age_controller.dart';
import '../../../main.dart';

class Age extends StatefulWidget {
  final AgeController controller;

  const Age({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Age> createState() => _GuideAgeState();
}

class _GuideAgeState extends State<Age> {
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
          widget.controller.currentLabels['age']!,
          style: const TextStyle(
            color: Color(0xFF353535),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFF2F3F7)),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int?>(
                  valueListenable: widget.controller.selectedYearNotifier,
                  builder: (context, selectedYear, _) {
                    return DropdownButtonFormField<int>(
                      value: selectedYear,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
                      hint: Text(
                        widget.controller.currentLabels['year'] ?? '년도',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                        ),
                      ),
                      items: widget.controller.years.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(
                            '$year${widget.controller.currentLabels['year_suffix'] ?? '년'}',
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        widget.controller.updateBirthDate(
                          value,
                          widget.controller.selectedMonthNotifier.value,
                          widget.controller.selectedDayNotifier.value,
                        );
                      },
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300,
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 1,
                height: 45,
                color: const Color(0xFFF2F3F7),
              ),
              Expanded(
                child: ValueListenableBuilder<int?>(
                  valueListenable: widget.controller.selectedMonthNotifier,
                  builder: (context, selectedMonth, _) {
                    return DropdownButtonFormField<int>(
                      value: selectedMonth,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
                      hint: Text(
                        widget.controller.currentLabels['month'] ?? '월',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                        ),
                      ),
                      items: widget.controller.months.map((month) {
                        return DropdownMenuItem(
                          value: month,
                          child: Text(
                            '$month${widget.controller.currentLabels['month_suffix'] ?? '월'}',
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        widget.controller.updateBirthDate(
                          widget.controller.selectedYearNotifier.value,
                          value,
                          widget.controller.selectedDayNotifier.value,
                        );
                      },
                      dropdownColor: Colors.white,
                      menuMaxHeight: 300,
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 1,
                height: 45,
                color: const Color(0xFFF2F3F7),
              ),
              Expanded(
                child: ValueListenableBuilder<List<int>>(
                  valueListenable: widget.controller.daysNotifier,
                  builder: (context, days, _) {
                    return ValueListenableBuilder<int?>(
                      valueListenable: widget.controller.selectedDayNotifier,
                      builder: (context, selectedDay, _) {
                        return DropdownButtonFormField<int>(
                          value: selectedDay,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
                          hint: Text(
                            widget.controller.currentLabels['day'] ?? '일',
                            style: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 12,
                            ),
                          ),
                          items: days.map((day) {
                            return DropdownMenuItem(
                              value: day,
                              child: Text(
                                '$day${widget.controller.currentLabels['day_suffix'] ?? '일'}',
                                style: const TextStyle(
                                  color: Color(0xFF353535),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            widget.controller.updateBirthDate(
                              widget.controller.selectedYearNotifier.value,
                              widget.controller.selectedMonthNotifier.value,
                              value,
                            );
                          },
                          dropdownColor: Colors.white,
                          menuMaxHeight: 300,
                          style: const TextStyle(
                            color: Color(0xFF353535),
                            fontSize: 12,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}