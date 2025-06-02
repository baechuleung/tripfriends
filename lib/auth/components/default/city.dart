import 'package:flutter/material.dart';
import '../../controller/default/city_controller.dart';
import '../../../main.dart';

class City extends StatefulWidget {
  final CityController controller;

  const City({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<City> createState() => _CityState();
}

class _CityState extends State<City> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.controller.isLoadingCitiesNotifier,
      builder: (context, isLoadingCities, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.controller.cityLoadErrorNotifier,
          builder: (context, cityLoadError, _) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: widget.controller.citiesNotifier,
              builder: (context, cities, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: widget.controller.selectedCityNotifier,
                  builder: (context, selectedCity, _) {
                    final hasCountry = widget.controller.countryController.text.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.controller.currentLabels['city']!,
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
                            value: selectedCity,
                            hint: Container(
                              padding: const EdgeInsets.only(left: 16),
                              child: Text(
                                !hasCountry
                                    ? widget.controller.currentLabels['select_country_first']!
                                    : isLoadingCities
                                    ? widget.controller.currentLabels['loading_cities']!
                                    : cityLoadError
                                    ? widget.controller.currentLabels['no_cities_found']!
                                    : widget.controller.currentLabels['city_dec']!,
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
                              return cities.map((city) {
                                final code = city['code'] as String;
                                return Container(
                                  padding: const EdgeInsets.only(left: 16),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    widget.controller.getCityDisplayName(code, currentCountryCode),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF353535),
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            items: !hasCountry || isLoadingCities || cityLoadError || cities.isEmpty
                                ? null
                                : cities.map((city) {
                              final code = city['code'] as String;
                              final displayName = widget.controller.getCityDisplayName(code, currentCountryCode);

                              return DropdownMenuItem<String>(
                                value: code,
                                child: Text(
                                  displayName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF353535),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: !hasCountry || isLoadingCities || cityLoadError || cities.isEmpty
                                ? null
                                : (String? value) {
                              if (value != null) {
                                widget.controller.city = value;
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
          },
        );
      },
    );
  }
}