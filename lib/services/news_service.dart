import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';

class NewsService {
  // API Key từ NewsData.io
  static const String apiKey = 'pub_6c9d2fe4b0174ef287dde5aa472f2a75';
  static const String newsDataUrl = 'https://newsdata.io/api/1/latest';

  // RSS URLs từ báo Việt
  static const List<String> rssUrls = [
    'https://vnexpress.net/rss/thu-cung.rss', // VnExpress thú cưng (chính)
    'https://vnexpress.net/rss/khoa-hoc.rss', // Khoa học có bài về động vật
    'https://tuoitre.vn/rss/lối-sống.rss', // Lối sống của Tuổi Trẻ
    'https://thanhnien.vn/rss/thoi-trang.rss', // Thời trang có bài về thú cưng
  ];

  // Lấy tin tức từ kết hợp NewsData (chính) + RSS (backup)
  static Future<List<Map<String, dynamic>>> fetchPetNews() async {
    List<Map<String, dynamic>> allNews = [];

    try {
      // 1. Thử lấy từ NewsData trước (chính)
      final newsDataArticles = await _fetchNewsData();
      allNews.addAll(newsDataArticles);
    } catch (e) {
      print('NewsData error: $e');
    }

    try {
      // 2. Lấy từ RSS báo Việt (backup + thêm)
      final rssArticles = await _fetchRssPetNews();
      // Thêm RSS articles nếu chưa có RSS url trong NewsData
      for (var rssArticle in rssArticles) {
        if (!allNews.any((n) => n['url'] == rssArticle['url'])) {
          allNews.add(rssArticle);
        }
      }
    } catch (e) {
      print('RSS error: $e');
    }

    // Nếu không có bài nào, trả về fallback
    if (allNews.isEmpty) {
      return _getDefaultNews();
    }

    return allNews;
  }

  // Fetch từ NewsData API - chỉ lấy bài về thú cưng/pets
  static Future<List<Map<String, dynamic>>> _fetchNewsData() async {
    List<dynamic> allArticles = [];

    final searchQueries = ['pets', 'thú cưng', 'dog', 'cat', 'chó', 'mèo'];

    for (String query in searchQueries) {
      for (int page = 1; page <= 1; page++) {
        try {
          final response = await http.get(
            Uri.parse('$newsDataUrl?apikey=$apiKey&q=$query&country=vi&language=vi&page=$page'),
            headers: {'Content-Type': 'application/json'},
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['status'] == 'success' && data['results'] != null) {
              allArticles.addAll(data['results']);
            }
          }
        } catch (e) {
          print('NewsData query error for "$query": $e');
        }
      }
    }

    return _filterPetArticles(allArticles, source: 'NewsData');
  }

  // Fetch từ RSS báo Việt - chỉ lấy bài về thú cưng
  static Future<List<Map<String, dynamic>>> _fetchRssPetNews() async {
    List<Map<String, dynamic>> allArticles = [];

    for (String rssUrl in rssUrls) {
      try {
        final response = await http.get(Uri.parse(rssUrl)).timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw Exception('Timeout'),
        );

        if (response.statusCode == 200) {
          final rssFeed = RssFeed.parse(response.body);

          for (var item in rssFeed.items ?? []) {
            final title = item.title ?? '';
            final description = item.description ?? '';
            final content = item.content?.value ?? '';
            final fullText = '$title $description $content'.toLowerCase();

            // Chỉ lọc bài liên quan đến thú cưng (không lọc theo category)
            if (_isPetRelated(fullText) &&
                item.enclosure?.url != null &&
                description.isNotEmpty) {
              allArticles.add({
                'title': title,
                'description': _stripHtml(description),
                'content': _stripHtml(content.isNotEmpty ? content : description),
                'image': item.enclosure?.url ?? item.media?.firstOrNull?.url ?? '',
                'url': item.link ?? '',
                'source': _getSourceName(rssUrl),
                'author': item.author ?? _getSourceName(rssUrl),
                'date': _formatDate(item.pubDate?.toString()),
                'category': 'Tất cả',
                'readTime': _estimateReadTime(content.isNotEmpty ? content : description),
              });
            }
          }
        }
      } catch (e) {
        print('RSS error for $rssUrl: $e');
      }
    }

    return allArticles;
  }

  // Lọc bài liên quan đến thú cưng - strict
  static bool _isPetRelated(String text) {
    // Từ khóa chính về thú cưng
    final mainKeywords = [
      'thú cưng', 'pet', 'chó', 'dog', 'mèo', 'cat',
      'rabbit', 'thỏ', 'bird', 'chim', 'puppy', 'kitten',
      'động vật', 'hamster', 'parrot', 'aquarium'
    ];

    // Từ khóa loại trừ (để bỏ bài không liên quan)
    final excludeKeywords = [
      'nhà máy', 'factory', 'máy tính', 'laptop', 'iphone',
      'điện thoại', 'ô tô', 'car', 'máy lạnh', 'túi xách',
      'thời trang', 'quần áo', 'dép', 'giày', 'trang sức'
    ];

    // Nếu có từ loại trừ thì bỏ
    if (excludeKeywords.any((keyword) => text.contains(keyword))) {
      return false;
    }

    // Phải có ít nhất 1 từ khóa chính
    return mainKeywords.any((keyword) => text.contains(keyword));
  }

  // Lọc bài từ danh sách bài (NewsData) - chỉ lấy bài về thú cưng
  static List<Map<String, dynamic>> _filterPetArticles(
    List<dynamic> articles, {
    String source = 'NewsData',
  }) {
    List<Map<String, dynamic>> filtered = [];

    for (var article in articles) {
      final title = (article['title'] ?? '').toLowerCase();
      final description = (article['description'] ?? '').toLowerCase();
      final content = (article['content'] ?? '').toLowerCase();
      final fullText = '$title $description $content';

      // Chỉ lấy bài liên quan đến thú cưng (không lọc theo category)
      if (article['image_url'] != null &&
          article['description'] != null &&
          article['description'].toString().isNotEmpty &&
          _isPetRelated(fullText)) {
        filtered.add({
          'title': article['title'] ?? 'Không có tiêu đề',
          'description': article['description'] ?? '',
          'content': article['content'] ?? article['description'] ?? '',
          'image': article['image_url'] ?? '',
          'url': article['link'] ?? '',
          'source': article['source_id'] ?? source,
          'author': article['source_name'] ?? source,
          'date': _formatDate(article['pubDate']),
          'category': 'Tất cả',
          'readTime': _estimateReadTime(article['content'] ?? article['description'] ?? ''),
        });
      }
    }

    return filtered;
  }

  // Xoá HTML tags
  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
  }

  // Lấy tên nguồn từ RSS URL
  static String _getSourceName(String url) {
    if (url.contains('vnexpress')) return 'VnExpress';
    if (url.contains('tuoitre')) return 'Tuổi Trẻ';
    if (url.contains('thanhnien')) return 'Thanh Niên';
    if (url.contains('24h')) return '24h';
    return 'Báo Việt';
  }

  // Định dạng ngày tháng
  static String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Gần đây';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return 'Hôm nay';
      } else if (diff.inDays == 1) {
        return 'Hôm qua';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${date.day} ${_monthName(date.month)} ${date.year}';
      }
    } catch (e) {
      return 'Gần đây';
    }
  }

  // Tên tháng
  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Ước tính thời gian đọc
  static String _estimateReadTime(String text) {
    if (text.isEmpty) return '1 phút';
    
    final words = text.split(' ').length;
    final minutes = (words / 200).ceil();
    
    if (minutes < 1) return '1 phút';
    return '$minutes phút';
  }

  // Lấy tin tức từ cache hoặc API
  static Future<List<Map<String, dynamic>>> getPetNews() async {
    try {
      return await fetchPetNews();
    } catch (e) {
      // Nếu lỗi, trả về tin tức mẫu
      return _getDefaultNews();
    }
  }

  // Tin tức mẫu khi API lỗi
  static List<Map<String, dynamic>> _getDefaultNews() {
    return [
      {
        'title': 'Những loài thú cưng được yêu thích nhất hiện nay',
        'category': 'Tất cả',
        'image': 'lib/res/drawables/setting/tag-SK.png',
        'author': 'Pet Magazine',
        'date': 'Hôm nay',
        'readTime': '5 phút',
        'content': 'Những loài thú cưng phổ biến nhất bao gồm chó, mèo, chim, thỏ và chuột. Mỗi loài có những đặc điểm và nhu cầu chăm sóc khác nhau.',
        'description': 'Những loài thú cưng phổ biến nhất bao gồm chó, mèo, chim, thỏ và chuột. Mỗi loài có những đặc điểm và nhu cầu chăm sóc khác nhau.',
        'url': '',
      },
      {
        'title': 'Cách chăm sóc thú cưng của bạn một cách tốt nhất',
        'category': 'Tất cả',
        'image': 'lib/res/drawables/setting/tag-VN.png',
        'author': 'Pet Care Expert',
        'date': 'Hôm qua',
        'readTime': '7 phút',
        'content': 'Chăm sóc thú cưng đúng cách giúp chúng khỏe mạnh, vui vẻ và sống lâu hơn. Hãy cung cấp dinh dưỡng tốt, nước sạch và tình yêu thương.',
        'description': 'Chăm sóc thú cưng đúng cách giúp chúng khỏe mạnh, vui vẻ và sống lâu hơn. Hãy cung cấp dinh dưỡng tốt, nước sạch và tình yêu thương.',
        'url': '',
      },
      {
        'title': 'Những điều thú cưng muốn bạn biết',
        'category': 'Tất cả',
        'image': 'lib/res/drawables/setting/tag-HL.jpg',
        'author': 'Pet Behavior',
        'date': '2 ngày trước',
        'readTime': '6 phút',
        'content': 'Thú cưng của bạn cần sự chú ý, tình yêu và hiểu biết về nhu cầu của chúng. Lắng nghe các tín hiệu từ chúng để có mối quan hệ tốt hơn.',
        'description': 'Thú cưng của bạn cần sự chú ý, tình yêu và hiểu biết về nhu cầu của chúng. Lắng nghe các tín hiệu từ chúng để có mối quan hệ tốt hơn.',
        'url': '',
      },
    ];
  }
}
