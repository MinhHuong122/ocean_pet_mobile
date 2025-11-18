import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  int selectedCategory = 0;
  List<Map<String, dynamic>> allNews = [];
  bool isLoading = true;
  String errorMessage = '';

  final List<String> categories = [
    'Tất cả',
  ];

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => isLoading = true);
    try {
      final news = await NewsService.getPetNews();
      setState(() {
        allNews = news;
        isLoading = false;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải tin tức: $e';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredNews {
    if (selectedCategory == 0) {
      return allNews;
    }
    return allNews
        .where((news) => news['category'] == categories[selectedCategory])
        .toList();
  }

  void _openUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có link bài viết', style: GoogleFonts.afacad()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể mở link: $e', style: GoogleFonts.afacad()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            'Tin tức',
            style: GoogleFonts.afacad(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                _loadNews();
              },
              child: Icon(Icons.refresh, color: Colors.black),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNews,
        color: const Color(0xFF8B5CF6),
        child: SafeArea(
          child: isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: Color(0xFF8B5CF6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải tin tức...',
                        style: GoogleFonts.afacad(),
                      ),
                    ],
                  ),
                )
              : errorMessage.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              errorMessage,
                              style: GoogleFonts.afacad(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadNews,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Thử lại', style: GoogleFonts.afacad()),
                          ),
                        ],
                      ),
                    )
                  : filteredNews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.newspaper, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'Không có bài viết',
                                style: GoogleFonts.afacad(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: [
                                    ...filteredNews
                                        .map((news) => _newsCard(context, news))
                                        .toList(),
                                    SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
        ),
      ),
    );
  }

  Widget _newsCard(BuildContext context, Map<String, dynamic> news) {
    return GestureDetector(
      onTap: () {
        _showNewsDetail(context, news);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: news['image'].toString().startsWith('http')
                  ? Image.network(
                      news['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    )
                  : Image.asset(
                      news['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        );
                      },
                    ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5CF6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      news['category'] ?? 'Tất cả',
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Title
                  Text(
                    news['title'] ?? 'Không có tiêu đề',
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Meta info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Color(0xFF8B5CF6),
                            child: Text(
                              (news['author'] ?? 'N')[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news['author'] ?? 'NewsData',
                                style: GoogleFonts.afacad(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                news['date'] ?? 'Gần đây',
                                style: GoogleFonts.afacad(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        news['readTime'] ?? '1 phút',
                        style: GoogleFonts.afacad(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewsDetail(BuildContext context, Map<String, dynamic> news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                
                // Title
                Text(
                  news['title'] ?? 'Không có tiêu đề',
                  style: GoogleFonts.afacad(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12),
                
                // Meta info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${news['author'] ?? 'NewsData'} • ${news['date'] ?? 'Gần đây'}',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        news['category'] ?? 'Tất cả',
                        style: GoogleFonts.afacad(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Main image
                if ((news['image'] ?? '').isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(news['image']),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {},
                      ),
                    ),
                    child: news['image'].toString().startsWith('http')
                        ? Image.network(
                            news['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image_not_supported),
                              );
                            },
                          )
                        : SizedBox.shrink(),
                  ),
                SizedBox(height: 16),
                
                // Description/Summary
                if ((news['description'] ?? '').isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF8B5CF6).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      news['description'] ?? '',
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.grey[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                
                // Full content
                Text(
                  news['content'] ?? 'Không có nội dung',
                  style: GoogleFonts.afacad(
                    fontSize: 15,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),
                
                // Read full article button
                if ((news['url'] ?? '').isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      _openUrl(news['url']);
                    },
                    icon: Icon(Icons.open_in_new),
                    label: Text(
                      'Đọc bài viết đầy đủ',
                      style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
