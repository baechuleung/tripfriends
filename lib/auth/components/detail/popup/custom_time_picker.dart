import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay? startTime;
  final bool isStartTime;

  const CustomTimePicker({
    Key? key,
    this.startTime,
    required this.isStartTime,
  }) : super(key: key);

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int selectedHour = 0;
  final FixedExtentScrollController _controller = FixedExtentScrollController();

  List<int> _generateInfiniteHours() {
    List<int> validHours = [];

    if (widget.isStartTime) {
      // 시작시간은 항상 1~24 선택 가능
      for (int i = 1; i <= 24; i++) {
        validHours.add(i);
      }
    } else {
      // 종료시간은 시작시간+1 ~ 24까지만 선택 가능
      if (widget.startTime != null) {
        int startHour = widget.startTime!.hour == 0 ? 24 : widget.startTime!.hour;
        for (int i = startHour + 1; i <= 24; i++) {
          validHours.add(i);
        }
      } else {
        // 시작시간이 선택되지 않은 경우 선택 불가능하도록 빈 리스트
        return [];
      }
    }

    const int multiplier = 100;
    List<int> hours = [];
    for (int i = 0; i < multiplier; i++) {
      hours.addAll(validHours);
    }
    return hours;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hours = _generateInfiniteHours();
      _controller.jumpToItem(hours.length ~/ 2);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _generateInfiniteHours();

    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 100,
                  right: 100,
                  top: 40,
                  child: AbsorbPointer(
                    child: Container(
                      height: 40,
                      decoration: ShapeDecoration(
                        color: const Color(0x7CA8CEFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListWheelScrollView(
                    controller: _controller,
                    itemExtent: 40,
                    useMagnifier: true,
                    magnification: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    diameterRatio: 1.5,
                    perspective: 0.005,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedHour = hours[index];
                      });
                    },
                    children: hours.map((hour) {
                      bool isSelected = selectedHour == hour;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          hour.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF353535)
                                : const Color(0xFF999999),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFE8E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        color: Color(0xFFFF5050),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8F2FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TimeOfDay(hour: selectedHour, minute: 0),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.transparent,
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Color(0xFF237AFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}