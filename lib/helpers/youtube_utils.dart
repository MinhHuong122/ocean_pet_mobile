// lib/helpers/youtube_utils.dart
/// Trích xuất YouTube Video ID từ mọi loại link
/// Hỗ trợ: https://youtube.com/watch?v=...
///        https://youtu.be/...
///        https://youtube.com/shorts/...
String? extractYoutubeId(String url) {
  final regExp = RegExp(
    r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([^"&?\/\s]{11})',
    caseSensitive: false,
  );
  
  final match = regExp.firstMatch(url);
  return match?.group(1);
}

/// Tạo URL thumbnail từ YouTube Video ID
/// quality: 'maxresdefault' (4K) | 'sddefault' (720p) | 'hqdefault' (480p) | 'default' (120p)
String getYoutubeThumbnail(String videoId, {String quality = 'maxresdefault'}) {
  return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
}

/// Kiểm tra xem link có phải YouTube hay không
bool isValidYoutubeUrl(String url) {
  return extractYoutubeId(url) != null;
}
