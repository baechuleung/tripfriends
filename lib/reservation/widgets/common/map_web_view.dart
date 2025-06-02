import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../services/translation_service.dart';

class MapWebView extends StatefulWidget {
  final String address;

  const MapWebView({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<MapWebView> createState() => _MapWebViewState();
}

class _MapWebViewState extends State<MapWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    // URL 인코딩
    final String encodedAddress = Uri.encodeComponent(widget.address);
    // 구글 지도 URL 생성
    final String mapUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    // 웹뷰 컨트롤러 초기화
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(mapUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translationService.get('location_map', '위치 지도')),
        backgroundColor: const Color(0xFF3182F6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 새로고침 버튼
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3182F6)),
              ),
            ),
        ],
      ),
    );
  }
}