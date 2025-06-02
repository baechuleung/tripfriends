import 'package:flutter/material.dart';
import '../../controller/default/nationality_controller.dart';
import '../../../main.dart';

class Nationality extends StatefulWidget {
  final NationalityController controller;

  const Nationality({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Nationality> createState() => _NationalityState();
}

class _NationalityState extends State<Nationality> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.controller.countriesNotifier,
      builder: (context, countries, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: widget.controller.selectedCountryNotifier,
          builder: (context, selectedCountry, _) {
            // 허용된 국가 코드만 필터링
            final filteredCountries = countries.where(
                    (country) => widget.controller.allowedCountryCodes.contains(country['code'])
            ).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.controller.currentLabels['country']!,
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 45,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 1, color: Color(0xFFF2F3F7)),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCountry,
                    hint: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        widget.controller.currentLabels['country_dec']!,
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    icon: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF999999)),
                    ),
                    selectedItemBuilder: (BuildContext context) {
                      return filteredCountries.map((country) {
                        final code = country['code'] as String;
                        final displayName = widget.controller.getCountryDisplayName(code, currentCountryCode);

                        return Container(
                          padding: const EdgeInsets.only(left: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/country_code/$code.png',
                                width: 24,
                                height: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(Icons.flag, size: 16, color: Colors.grey),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF353535),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                    items: filteredCountries.map((country) {
                      final code = country['code'] as String;
                      final displayName = widget.controller.getCountryDisplayName(code, currentCountryCode);

                      return DropdownMenuItem<String>(
                        value: code,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/country_code/$code.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Icon(Icons.flag, size: 16, color: Colors.grey),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        widget.controller.nationality = value;
                      }
                    },
                    dropdownColor: Colors.white,
                    menuMaxHeight: 400,
                    style: const TextStyle(
                      color: Color(0xFF353535),
                      fontSize: 12,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}