// 미디어 타입 정의
enum MediaType {
  image,
  video,
}

// 미디어 정보 클래스
class MediaInfo {
  final String path;
  final MediaType type;

  MediaInfo({
    required this.path,
    required this.type,
  });

  // Firestore 저장용 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'type': type == MediaType.image ? 'image' : 'video',
    };
  }

  // Firestore 데이터로부터 생성
  factory MediaInfo.fromMap(Map<String, dynamic> map) {
    return MediaInfo(
      path: map['path'] as String,
      type: map['type'] == 'image' ? MediaType.image : MediaType.video,
    );
  }
}