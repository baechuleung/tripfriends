import 'package:flutter/material.dart';
import 'dart:io';
import '../../controller/default/document_upload_controller.dart';
import '../../../main.dart';

class DocumentUpload extends StatefulWidget {
  final DocumentUploadController controller;

  const DocumentUpload({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String?>>(
      valueListenable: widget.controller.documentImagesNotifier,
      builder: (context, documentPaths, _) {
        final validPaths = documentPaths.where((path) => path != null && path.isNotEmpty).toList();

        return ValueListenableBuilder<bool>(
          valueListenable: widget.controller.isLoadingNotifier,
          builder: (context, isLoading, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.controller.currentLabels['document_upload']!,
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFF5050),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.controller.currentLabels['document_upload_desc']!,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF3182F6),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.controller.currentLabels['photo_guide']!,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 파일 첨부 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () async {
                            try {
                              await widget.controller.pickImage();
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
                                );
                              }
                            }
                          },
                          icon: isLoading
                              ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                          )
                              : const Icon(Icons.add_photo_alternate, size: 18),
                          label: Text(
                            widget.controller.currentLabels['upload_button']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3182F6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                      // 첨부된 이미지 표시
                      if (validPaths.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFE5E5E5)),
                        const SizedBox(height: 16),
                        Text(
                          "첨부된 파일 (${validPaths.length}/3)",
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            validPaths.length,
                                (index) => _buildThumbnail(validPaths[index]!, index),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildThumbnail(String path, int index) {
    final isRemoteImage = path.startsWith('http');

    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xFFE5E5E5)),
            image: DecorationImage(
              image: isRemoteImage
                  ? NetworkImage(path) as ImageProvider
                  : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => widget.controller.removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}