import 'package:flutter/material.dart';
import '../../../services/translation_service.dart';
import 'screens/manual_detail_page.dart';

// 매뉴얼 위젯 (StatefulWidget)
class TripFriendsManual extends StatefulWidget {
  final TranslationService translationService;

  const TripFriendsManual({
    Key? key,
    required this.translationService,
  }) : super(key: key);

  @override
  State<TripFriendsManual> createState() => _TripFriendsManualState();
}

class _TripFriendsManualState extends State<TripFriendsManual> {
  // 초기값을 false로 설정하여 기본적으로 닫혀 있게 함
  bool isVisible = false;

  void toggleVisibility() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  @override
  void didUpdateWidget(TripFriendsManual oldWidget) {
    super.didUpdateWidget(oldWidget);
    // TranslationService가 변경된 경우를 감지하여 UI를 다시 빌드
    if (widget.translationService != oldWidget.translationService) {
      setState(() {
        // 언어 변경 시 상태 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // isVisible=false이면 닫힌 상태(ManualHandle)
    // isVisible=true이면 열린 상태(ManualContent)
    return isVisible
        ? ManualContent(
      translationService: widget.translationService,
      onToggle: toggleVisibility,
    )
        : ManualHandle(
      onToggle: toggleVisibility,
    );
  }
}

// 열린 상태의 매뉴얼
class ManualContent extends StatelessWidget {
  final TranslationService translationService;
  final VoidCallback onToggle;

  const ManualContent({
    Key? key,
    required this.translationService,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 현재 언어로 매뉴얼 텍스트 가져오기
    final manualText = translationService.get('trip_friends_manual', '트립프렌즈 이용방법');

    return Container(
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 매뉴얼 내용 부분
          InkWell(
            onTap: () {
              // 매뉴얼 상세 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManualDetailPage(
                    translationService: translationService,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // 아이콘 (빨간색 확성기)
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.campaign,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 제목 텍스트
                  Expanded(
                    child: Text(
                      manualText,
                      style: const TextStyle(
                        color: Color(0xFF4E5968),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // 오른쪽 화살표 (이동 표시)
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // 핸들 추가
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 닫힌 상태에서 보이는 핸들
class ManualHandle extends StatelessWidget {
  final VoidCallback onToggle;

  const ManualHandle({
    Key? key,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onToggle,
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D0D0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}