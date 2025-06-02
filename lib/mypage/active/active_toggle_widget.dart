import 'package:flutter/material.dart';
import 'active_controller.dart';
import '../../services/translation_service.dart';

class ActiveToggleWidget extends StatefulWidget {
  final TranslationService translationService;

  const ActiveToggleWidget({
    Key? key,
    required this.translationService,
  }) : super(key: key);

  @override
  State<ActiveToggleWidget> createState() => _ActiveToggleWidgetState();
}

class _ActiveToggleWidgetState extends State<ActiveToggleWidget> {
  late ActiveController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActiveController();
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // 좌우 마진 16
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.translationService.get('friend_status', '프렌즈 활동 상태'),
                      style: const TextStyle(
                        color: const Color(0xFF4E5968),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.isActive
                          ? widget.translationService.get('status_active', '활성화 상태에서는 예약을 받을 수 있습니다.')
                          : widget.translationService.get('status_inactive', 'OFF 상태에서는 예약을 받을 수 없습니다.'),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF4E5968),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _controller.isActive,
                  onChanged: (_) async {
                    await _controller.toggleActive();
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    super.dispose();
  }
}