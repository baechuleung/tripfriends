import 'package:flutter/material.dart';
import '../../../translations/reservation_translations.dart';
import '../../../main.dart' show currentCountryCode, languageChangeController;
import 'dart:async';

class CurrentReservationHeaderWidget extends StatefulWidget {
  final int count;

  const CurrentReservationHeaderWidget({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  State<CurrentReservationHeaderWidget> createState() => _CurrentReservationHeaderWidgetState();
}

class _CurrentReservationHeaderWidgetState extends State<CurrentReservationHeaderWidget> {
  String _currentLanguage = 'KR';
  StreamSubscription<String>? _languageSubscription;

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;

    // 언어 변경 리스너 등록
    _languageSubscription = languageChangeController.stream.listen((newLanguage) {
      if (mounted) {
        setState(() {
          _currentLanguage = newLanguage;
        });
      }
    });
  }

  @override
  void dispose() {
    _languageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text(
            ReservationTranslations.getTranslation('current_reservations', _currentLanguage),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF353535)
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF237AFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${widget.count}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500
              ),
            ),
          ),
        ],
      ),
    );
  }
}