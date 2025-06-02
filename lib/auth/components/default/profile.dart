import 'package:flutter/material.dart';
import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    widget.controller.loadTranslations(currentCountryCode);
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.controller.currentLabels['profileImage']!,
                  style: const TextStyle(
                    color: Color(0xFF353535),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isLoading ? null : _handlePickImage,
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: Text(widget.controller.currentLabels['uploadImage']!),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF3182F6),
                          side: const BorderSide(color: Color(0xFF3182F6), width: 1),
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
                        icon: const Icon(Icons.videocam_rounded, size: 18),
                        label: Text(widget.controller.currentLabels['uploadVideo']!),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF28a745),
                          side: const BorderSide(color: Color(0xFF28a745), width: 1),
                          backgroundColor: const Color(0xFFE6F5EB),
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
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFFE082), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Color(0xFFFFB300), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.controller.currentLabels['signupBonus']!,
                          style: const TextStyle(
                            color: Color(0xFF5D4037),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (mediaList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.controller.currentLabels['uploadedMedia']} (${mediaList.length}개)',
                        style: const TextStyle(
                          color: Color(0xFF353535),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 120,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: mediaList.length,
                      itemBuilder: (context, index) {
                        final mediaInfo = mediaList[index];

                        return Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: index == 0
                                  ? const Color(0xFF3182F6)
                                  : Colors.grey[300]!,
                              width: index == 0 ? 2 : 1,
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

                              if (index == 0)
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
                                      widget.controller.currentLabels['mainPhoto']!,
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
                        );
                      },
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}