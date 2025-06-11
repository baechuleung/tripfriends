// features/profile/widgets/profile_media_slider.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/profile_media_service.dart';

class ProfileMediaSlider extends StatefulWidget {
  final bool isLoading;
  final Map<String, dynamic> userData;
  final ProfileMediaService? mediaService;
  final int reviewCount;
  final Map<String, String> currentLabels;

  const ProfileMediaSlider({
    super.key,
    required this.isLoading,
    required this.userData,
    required this.mediaService,
    required this.reviewCount,
    required this.currentLabels,
  });

  @override
  State<ProfileMediaSlider> createState() => _ProfileMediaSliderState();
}

class _ProfileMediaSliderState extends State<ProfileMediaSlider> {
  late PageController _pageController;
  int _currentMediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 미디어가 없거나 로딩 중이면 로딩 표시기 또는 기본 이미지 표시
    if (widget.isLoading) {
      return _buildLoadingIndicator();
    }

    // 미디어가 없으면 기본 이미지 사용
    if (widget.mediaService?.profileMedia.isEmpty ?? true) {
      widget.mediaService?.setDefaultMedia(widget.userData);
    }

    final mediaItems = widget.mediaService?.profileMedia ?? [];
    if (mediaItems.isEmpty) {
      return _buildLoadingIndicator();
    }

    final isApproved = widget.userData['isApproved'] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 350, // 높이 조정 - 더 크게
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          children: [
            // 미디어 슬라이더
            SizedBox.expand(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentMediaIndex = index;
                    if (widget.mediaService != null) {
                      widget.mediaService!.currentMediaIndex = index;
                    }
                  });
                },
                itemCount: mediaItems.length,
                itemBuilder: (context, index) {
                  return _buildMediaItem(mediaItems[index]);
                },
              ),
            ),

            // 페이지 인디케이터
            if (mediaItems.length > 1)
              _buildPageIndicator(mediaItems.length),

            // 그라데이션 오버레이
            _buildGradientOverlay(),

            // 별점 표시
            _buildRatingInfo(),

            // 이름과 Expert 아이콘
            _buildNameWithExpertBadge(),

            // 승인 상태
            _buildApprovalStatus(isApproved),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMediaItem(Map<String, dynamic> mediaItem) {
    if (mediaItem['type'] == 'video') {
      return _buildVideoPlayer(mediaItem['url']);
    } else {
      return _buildImageViewer(mediaItem['url']);
    }
  }

  Widget _buildVideoPlayer(String url) {
    final videoControllers = widget.mediaService?.videoControllers;

    // 아직 컨트롤러가 초기화되지 않은 경우
    if (videoControllers == null || !videoControllers.containsKey(url)) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 컨트롤러가 있는 경우 비디오 플레이어 반환
    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(videoControllers[url]!),
        // 재생/일시정지 버튼
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                widget.mediaService?.toggleVideoPlayback(url);
              });
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  videoControllers[url]!.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageViewer(String url) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // 이미지 로딩 최적화
        cacheWidth: 800, // 메모리에 캐시할 이미지 너비 제한
        cacheHeight: 800, // 메모리에 캐시할 이미지 높이 제한
        gaplessPlayback: true, // 이미지 전환 시 갭 없애기
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child; // 로딩 완료 시 원본 이미지 표시
          }
          // 로딩 중에는 진행 상황에 따른 프로그레스 표시
          return Center(
            child: loadingProgress.expectedTotalBytes != null
                ? CircularProgressIndicator(
              value: loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!,
            )
                : const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(int totalCount) {
    return Positioned(
      top: 10,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "${_currentMediaIndex + 1}/$totalCount",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.0, 0.3, 0.5, 0.7],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingInfo() {
    return Positioned(
      bottom: 65,
      left: 16,
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.yellow, size: 16),
          const SizedBox(width: 4),
          Text(
            "${(widget.userData['average_rating'] ?? 0.0).toStringAsFixed(1)}/5 (${widget.reviewCount})",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameWithExpertBadge() {
    return Positioned(
      bottom: 40,
      left: 16,
      child: Row(
        children: [
          Text(
            widget.userData['name'] ?? '이름 없음',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
          if (widget.userData['type'] == 'expert')
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Image.asset(
                'assets/guide/Expert.png',
                width: 20,
                height: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApprovalStatus(bool isApproved) {
    return Positioned(
      bottom: 10,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: ShapeDecoration(
          color: isApproved ? const Color(0xFFE7F1FF) : const Color(0xFFFFE8E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isApproved
                  ? widget.currentLabels['approval_complete'] ?? '승인 완료'
                  : widget.currentLabels['approval_waiting'] ?? '승인 대기중',
              style: TextStyle(
                color: isApproved ? const Color(0xFF3182F6) : const Color(0xFFFF3E6C),
                fontSize: 12,
                fontFamily: 'Spoqa Han Sans Neo',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}