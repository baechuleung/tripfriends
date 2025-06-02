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
                    valueListenable: widget.controller.countriesNotifier,
                    builder: (context, countries, _) {
                      final filteredCountries = countries.where(
                              (country) => widget.controller.allowedCountryCodes.contains(country['code'])
                      ).toList();

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          shrinkWrap: true,
                          itemCount: filteredCountries.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFE4E4E4),
                            indent: 0,
                            endIndent: 0,
                          ),
                          itemBuilder: (context, index) {
                            final country = filteredCountries[index];
                            final code = country['code'] as String;
                            final displayName = widget.controller.getCountryDisplayName(code, currentCountryCode);

                            return InkWell(
                              onTap: () {
                                widget.controller.nationality = code;
                                _removeOverlay();
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/country_code/$code.png',
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Icon(Icons.flag, size: 16, color: Colors.grey),
                                        );
                                      },
                                    ),
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
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.controller.countriesNotifier,
      builder: (context, countries, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: widget.controller.selectedCountryNotifier,
          builder: (context, selectedCountry, _) {
            final filteredCountries = countries.where(
                    (country) => widget.controller.allowedCountryCodes.contains(country['code'])
            ).toList();

            String? displayName;
            if (selectedCountry != null) {
              displayName = widget.controller.getCountryDisplayName(selectedCountry, currentCountryCode);
            }

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
                            if (selectedCountry != null)
                              Image.asset(
                                'assets/country_code/$selectedCountry.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Icon(Icons.flag, size: 16, color: Colors.grey),
                                  );
                                },
                              )
                            else
                              const Icon(Icons.language, size: 20, color: Color(0xFF999999)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                displayName ?? widget.controller.currentLabels['country_dec']!,
                                style: TextStyle(
                                  color: selectedCountry != null ? const Color(0xFF353535) : const Color(0xFF999999),
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
  }
}