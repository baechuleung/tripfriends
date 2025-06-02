import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../services/translation_service.dart';

class LocationTermsScreen extends StatefulWidget {
  const LocationTermsScreen({Key? key}) : super(key: key);

  @override
  _LocationTermsScreenState createState() => _LocationTermsScreenState();
}

class _LocationTermsScreenState extends State<LocationTermsScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  bool isLoading = true;
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    _initTranslations();
  }

  Future<void> _initTranslations() async {
    await _translationService.init();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _translationService.get('location_terms', '[필수] 위치기반 서비스 이용약관 동의'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SfPdfViewer.asset(
        'assets/data/pdf/location_terms.pdf',
        key: _pdfViewerKey,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            isLoading = false;
          });
        },
        canShowScrollHead: false,
        canShowScrollStatus: false,
        enableDoubleTapZooming: true,
        pageSpacing: 0,
        canShowPaginationDialog: false,
      ),
    );
  }
}