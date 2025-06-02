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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _toggleDropdown() {
    final hasCountry = widget.controller.countryController.text.isNotEmpty;
    final isLoadingCities = widget.controller.isLoadingCitiesNotifier.value;
    final cityLoadError = widget.controller.cityLoadErrorNotifier.value;
    final cities = widget.controller.citiesNotifier.value;

    if (!hasCountry || isLoadingCities || cityLoadError || cities.isEmpty) {
      return;
    }

    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showDropdown();
    }
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _removeOverlay();
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 반투명 배경
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // 화면 정중앙에 드롭다운 배치
            Center(
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32, // 양쪽 16px 여백
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: widget.controller.citiesNotifier,
                    builder: (context, cities, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: cities.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE4E4E4),
                            indent: 0,
                            endIndent: 0,
                          ),
                          itemBuilder: (context, index) {
                            final city = cities[index];
                            final code = city['code'] as String;
                            final displayName = widget.controller.getCityDisplayName(code, currentCountryCode);

                            return InkWell(
                              onTap: () {
                                widget.controller.city = code;
                                _removeOverlay();
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_city, size: 20, color: Color(0xFF353535)),
                                    const SizedBox(width: 12),
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

    Overlay.of(context).insert(_overlayEntry!);
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

                    String? displayName;
                    if (selectedCity != null) {
                      displayName = widget.controller.getCityDisplayName(selectedCity, currentCountryCode);
                    }

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
                        const SizedBox(height: 4),
                        CompositedTransformTarget(
                          link: _layerLink,
                          child: GestureDetector(
                            onTap: _toggleDropdown,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_city,
                                      size: 20,
                                      color: selectedCity != null ? const Color(0xFF353535) : const Color(0xFF999999),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        !hasCountry
                                            ? widget.controller.currentLabels['select_country_first']!
                                            : isLoadingCities
                                            ? widget.controller.currentLabels['loading_cities']!
                                            : cityLoadError
                                            ? widget.controller.currentLabels['no_cities_found']!
                                            : displayName ?? widget.controller.currentLabels['city_dec']!,
                                        style: TextStyle(
                                          color: selectedCity != null ? const Color(0xFF353535) : const Color(0xFF999999),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: const Color(0xFF999999),
                                    ),
                                  ],
                                ),
                              ),
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