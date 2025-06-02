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
  OverlayEntry? _yearOverlay;
  OverlayEntry? _monthOverlay;
  OverlayEntry? _dayOverlay;
  bool _isYearDropdownOpen = false;
  bool _isMonthDropdownOpen = false;
  bool _isDayDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  void dispose() {
    _removeAllOverlays();
    super.dispose();
  }

  void _removeAllOverlays() {
    _yearOverlay?.remove();
    _yearOverlay = null;
    _isYearDropdownOpen = false;

    _monthOverlay?.remove();
    _monthOverlay = null;
    _isMonthDropdownOpen = false;

    _dayOverlay?.remove();
    _dayOverlay = null;
    _isDayDropdownOpen = false;
  }

  void _showYearDropdown() {
    _removeAllOverlays();

    _yearOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _yearOverlay?.remove();
          _yearOverlay = null;
          setState(() {
            _isYearDropdownOpen = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
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
                      itemCount: widget.controller.years.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE4E4E4),
                        indent: 0,
                        endIndent: 0,
                      ),
                      itemBuilder: (context, index) {
                        final year = widget.controller.years[index];
                        final isSelected = year == widget.controller.selectedYearNotifier.value;

                        return InkWell(
                          onTap: () {
                            widget.controller.updateBirthDate(
                              year,
                              widget.controller.selectedMonthNotifier.value,
                              widget.controller.selectedDayNotifier.value,
                            );
                            _yearOverlay?.remove();
                            _yearOverlay = null;
                            setState(() {
                              _isYearDropdownOpen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            color: isSelected ? const Color(0xFFE8F2FF) : null,
                            child: Center(
                              child: Text(
                                '$year${widget.controller.currentLabels['year_suffix'] ?? '년'}',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
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

    Overlay.of(context).insert(_yearOverlay!);
    setState(() {
      _isYearDropdownOpen = true;
    });
  }

  void _showMonthDropdown() {
    _removeAllOverlays();

    _monthOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _monthOverlay?.remove();
          _monthOverlay = null;
          setState(() {
            _isMonthDropdownOpen = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
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
                      itemCount: widget.controller.months.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFE4E4E4),
                        indent: 0,
                        endIndent: 0,
                      ),
                      itemBuilder: (context, index) {
                        final month = widget.controller.months[index];
                        final isSelected = month == widget.controller.selectedMonthNotifier.value;

                        return InkWell(
                          onTap: () {
                            widget.controller.updateBirthDate(
                              widget.controller.selectedYearNotifier.value,
                              month,
                              widget.controller.selectedDayNotifier.value,
                            );
                            _monthOverlay?.remove();
                            _monthOverlay = null;
                            setState(() {
                              _isMonthDropdownOpen = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            color: isSelected ? const Color(0xFFE8F2FF) : null,
                            child: Center(
                              child: Text(
                                '$month${widget.controller.currentLabels['month_suffix'] ?? '월'}',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF353535),
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
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

    Overlay.of(context).insert(_monthOverlay!);
    setState(() {
      _isMonthDropdownOpen = true;
    });
  }

  void _showDayDropdown() {
    _removeAllOverlays();

    _dayOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _dayOverlay?.remove();
          _dayOverlay = null;
          setState(() {
            _isDayDropdownOpen = false;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
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
                  child: ValueListenableBuilder<List<int>>(
                    valueListenable: widget.controller.daysNotifier,
                    builder: (context, days, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shrinkWrap: true,
                          itemCount: days.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE4E4E4),
                            indent: 0,
                            endIndent: 0,
                          ),
                          itemBuilder: (context, index) {
                            final day = days[index];
                            final isSelected = day == widget.controller.selectedDayNotifier.value;

                            return InkWell(
                              onTap: () {
                                widget.controller.updateBirthDate(
                                  widget.controller.selectedYearNotifier.value,
                                  widget.controller.selectedMonthNotifier.value,
                                  day,
                                );
                                _dayOverlay?.remove();
                                _dayOverlay = null;
                                setState(() {
                                  _isDayDropdownOpen = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                color: isSelected ? const Color(0xFFE8F2FF) : null,
                                child: Center(
                                  child: Text(
                                    '$day${widget.controller.currentLabels['day_suffix'] ?? '일'}',
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xFF3182F6) : const Color(0xFF353535),
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_dayOverlay!);
    setState(() {
      _isDayDropdownOpen = true;
    });
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
        const SizedBox(height: 4),
        Row(
          children: [
            // 년도 드롭다운
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _showYearDropdown,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int?>(
                            valueListenable: widget.controller.selectedYearNotifier,
                            builder: (context, selectedYear, _) {
                              return Text(
                                selectedYear != null
                                    ? '$selectedYear${widget.controller.currentLabels['year_suffix'] ?? '년'}'
                                    : widget.controller.currentLabels['year'] ?? '년도',
                                style: TextStyle(
                                  color: selectedYear != null ? const Color(0xFF353535) : const Color(0xFF999999),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          _isYearDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF999999),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 월 드롭다운
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _showMonthDropdown,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int?>(
                            valueListenable: widget.controller.selectedMonthNotifier,
                            builder: (context, selectedMonth, _) {
                              return Text(
                                selectedMonth != null
                                    ? '$selectedMonth${widget.controller.currentLabels['month_suffix'] ?? '월'}'
                                    : widget.controller.currentLabels['month'] ?? '월',
                                style: TextStyle(
                                  color: selectedMonth != null ? const Color(0xFF353535) : const Color(0xFF999999),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          _isMonthDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF999999),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 일 드롭다운
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _showDayDropdown,
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<int?>(
                            valueListenable: widget.controller.selectedDayNotifier,
                            builder: (context, selectedDay, _) {
                              return Text(
                                selectedDay != null
                                    ? '$selectedDay${widget.controller.currentLabels['day_suffix'] ?? '일'}'
                                    : widget.controller.currentLabels['day'] ?? '일',
                                style: TextStyle(
                                  color: selectedDay != null ? const Color(0xFF353535) : const Color(0xFF999999),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        Icon(
                          _isDayDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF999999),
                          size: 20,
                        ),
                      ],
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