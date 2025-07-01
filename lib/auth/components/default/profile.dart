import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import '../../controller/default/profile_controller.dart';
import '../../controller/default/models/media_info.dart';
import '../../../main.dart';

class Profile extends StatefulWidget {
  final ProfileController controller;

  const Profile({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? _languageChangeSubscription;
  String _currentLanguage = '';

  @override
  void initState() {
    super.initState();
    _currentLanguage = currentCountryCode;
    widget.controller.loadTranslations(_currentLanguage);

    // 언어 변경 이벤트 구독
    _languageChangeSubscription = languageChangeController.stream.listen((String newLanguage) {
      if (_currentLanguage != newLanguage && mounted) {
        setState(() {
          _currentLanguage = newLanguage;
          widget.controller.loadTranslations(_currentLanguage);
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _languageChangeSubscription?.cancel();
    super.dispose();
  }

  // 이미지 선택 핸들러
  Future<void> _handlePickImage() async {
    try {
      final mediaInfo = await widget.controller.pickImage();
      if (mediaInfo != null) {
        widget.controller.addMedia(mediaInfo);
        widget.controller.scrollToEnd(_scrollController);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.controller.currentLabels['imageErrorMsg']!))
        );
      }
    }
  }

  // 비디오 선택 핸들러
  Future<void> _handlePickVideo() async {
    try {
      // 첫 번째 항목이 없거나 이미지가 아닌 경우 처리
      if (widget.controller.profileMediaList.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(widget.controller.currentLabels['firstItemImageError']!))
          );
        }
        return;
      }

      final mediaInfo = await widget.controller.pickVideo();
      if (mediaInfo != null) {
        widget.controller.addMedia(mediaInfo);
        widget.controller.scrollToEnd(_scrollController);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.controller.currentLabels['videoErrorMsg']!))
        );
      }
    }
  }

  // 미디어 아이템 삭제 핸들러
  Future<void> _handleRemoveMedia(int index) async {
    try {
      widget.controller.removeMedia(index);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.controller.currentLabels['deleteErrorMsg']!))
        );
      }
    }
  }

  // 대표 이미지로 설정
  void _handleSetMainImage(int index) {
    widget.controller.setMainImage(index);
  }

  Widget _buildImageThumbnail(MediaInfo mediaInfo) {
    if (mediaInfo.path.startsWith('http')) {
      return Image.network(
        mediaInfo.path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(mediaInfo.path),
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildVideoThumbnail(MediaInfo mediaInfo) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.video_library,
          color: Colors.white.withOpacity(0.7),
          size: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<MediaInfo>>(
      valueListenable: widget.controller.profileMediaNotifier,
      builder: (context, mediaList, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: widget.controller.isLoadingNotifier,
          builder: (context, isLoading, _) {
            return ValueListenableBuilder<int>(
              valueListenable: widget.controller.mainImageIndexNotifier,
              builder: (context, mainImageIndex, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.controller.currentLabels['profileImage'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF353535),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.controller.currentLabels['profileDescription'] ?? '',
                      style: const TextStyle(
                        color: Color(0xFF4E5968),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading ? null : _handlePickImage,
                            icon: const Icon(Icons.add_photo_alternate, size: 18),
                            label: Text(widget.controller.currentLabels['uploadImage'] ?? ''),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3182F6),
                              side: BorderSide.none,
                              backgroundColor: const Color(0xFFE6F0FF),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: isLoading || mediaList.isEmpty ? null : _handlePickVideo,
                            icon: const Icon(Icons.video_call_outlined, size: 18),
                            label: Text(widget.controller.currentLabels['uploadVideo'] ?? ''),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3182F6),
                              side: BorderSide.none,
                              backgroundColor: const Color(0xFFE6F0FF),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              disabledBackgroundColor: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    if (mediaList.isNotEmpty) ...[
                      SizedBox(
                        height: 120,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: mediaList.length,
                          key: ValueKey(mediaList.length),
                          itemBuilder: (context, index) {
                            final mediaInfo = mediaList[index];

                            return GestureDetector(
                              onTap: mediaInfo.type == MediaType.image
                                  ? () => _handleSetMainImage(index)
                                  : null,
                              child: Container(
                                key: ValueKey(mediaInfo.path),
                                width: 120,
                                height: 120,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: index == 0 && mediaInfo.type == MediaType.image
                                        ? const Color(0xFF3182F6)
                                        : Colors.grey[300]!,
                                    width: index == 0 && mediaInfo.type == MediaType.image ? 2 : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: double.infinity,
                                        child: mediaInfo.type == MediaType.image
                                            ? _buildImageThumbnail(mediaInfo)
                                            : _buildVideoThumbnail(mediaInfo),
                                      ),
                                    ),

                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _handleRemoveMedia(index),
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),

                                    if (index == 0 && mediaInfo.type == MediaType.image)
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF3182F6),
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            widget.controller.currentLabels['mainPhoto'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),

                                    if (mediaInfo.type == MediaType.video)
                                      Positioned.fill(
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: const Color(0xFFE5E5E5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '<${widget.controller.currentLabels['upload_guide_title'] ?? ''}>',
                            style: const TextStyle(
                              color: Color(0xFF353535),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 프로필 이미지 안내
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.report_gmailerrorred,
                                size: 20,
                                color: Color(0xFFFF5050),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.controller.currentLabels['profile_image_guide_title'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF353535),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• ${widget.controller.currentLabels['profile_image_guide_desc1'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                    Text(
                                      '• ${widget.controller.currentLabels['profile_image_guide_desc2'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 자기소개 동영상 안내
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.report_gmailerrorred,
                                size: 20,
                                color: Color(0xFFFF5050),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.controller.currentLabels['intro_video_guide_title'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF353535),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• ${widget.controller.currentLabels['intro_video_guide_desc1'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                    Text(
                                      '• ${widget.controller.currentLabels['intro_video_guide_desc2'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                    Text(
                                      '• ${widget.controller.currentLabels['intro_video_guide_desc3'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 적립금 지급 안내
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.report_gmailerrorred,
                                size: 20,
                                color: Color(0xFFFF5050),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.controller.currentLabels['reward_guide_title'] ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF353535),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '• ${widget.controller.currentLabels['reward_guide_desc'] ?? ''}',
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}