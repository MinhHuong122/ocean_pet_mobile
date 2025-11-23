import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int selectedTab = 0; // 0: Sắp tới, 1: Đang diễn ra, 2: Đã kết thúc
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allEvents = [];
  List<Map<String, dynamic>> filteredEvents = [];
  Set<String> favoriteEventIds = {};
  String selectedCategory = 'Tất cả';
  String selectedLocation = 'Tất cả';
  bool isLoading = false;
  
  final List<String> categories = [
    'Tất cả',
    'Hội chợ',
    'Huấn luyện',
    'Thời trang',
    'Sức khỏe',
    'Thể thao',
    'Nhận nuôi',
    'Cộng đồng',
  ];
  
  final List<String> locations = [
    'Tất cả',
    'Online',
    'Offline',
  ];

  final List<Map<String, dynamic>> localEvents = [
    {
      'id': '1',
      'title': 'Hội chợ chó cỏn cỏn',
      'date': '20 Nov 2024',
      'time': '09:00 - 17:00',
      'location': 'Tao Đàn Park, TP HCM',
      'category': 'Hội chợ',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 324,
      'description':
          'Hội chợ thú cưng lớn nhất năm với hơn 100 gian hàng bán thú cưng, phụ kiện, và dịch vụ chám sóc.',
      'isGoing': false,
      'status': 'upcoming',
      'rating': 4.5,
      'organizer': 'Pet Expo Vietnam',
      'price': 'Miễn phí',
    },
    {
      'id': '2',
      'title': 'Khoá huấn luyện chó miễn phí',
      'date': '22 Nov 2024',
      'time': '14:00 - 16:00',
      'location': 'Bark Park, Quận 1',
      'category': 'Huấn luyện',
      'image': 'lib/res/drawables/setting/tag-HL.jpg',
      'attendees': 58,
      'description':
          'Các trainer chuyên nghiệp sẽ hướng dẫn cách huấn luyện chó cơ bản miễn phí.',
      'isGoing': false,
      'status': 'upcoming',
      'rating': 4.8,
      'organizer': 'Dog Training Club',
      'price': 'Miễn phí',
    },
    {
      'id': '3',
      'title': 'Pet Fashion Show 2024',
      'date': '25 Nov 2024',
      'time': '18:00 - 20:30',
      'location': 'Diamond Plaza, TP HCM',
      'category': 'Thời trang',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'attendees': 512,
      'description':
          'Sàn diễn thời trang cho thú cưng với các bộ trang phục độc đáo và kỳ lạ.',
      'isGoing': false,
      'status': 'upcoming',
      'rating': 4.7,
      'organizer': 'Pet Fashion Vietnam',
      'price': '100.000đ',
    },
    {
      'id': '4',
      'title': 'Chương trình nhận nuôi thú cưng',
      'date': 'Đang diễn ra',
      'time': 'Hàng tuần',
      'location': 'Animal Rescue Center',
      'category': 'Nhận nuôi',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 1250,
      'description':
          'Chương trình giúp các bạn tìm được những chú thú cưng yêu thương để nhận nuôi.',
      'isGoing': true,
      'status': 'ongoing',
      'rating': 4.9,
      'organizer': 'Animal Rescue Center',
      'price': 'Miễn phí',
    },
    {
      'id': '5',
      'title': 'Cộng đồng yêu thích mèo',
      'date': 'Đang diễn ra',
      'time': 'Hàng tháng',
      'location': 'Online & Offline',
      'category': 'Cộng đồng',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'attendees': 3400,
      'description':
          'Cộng đồng những người yêu mèo chia sẻ kinh nghiệm và chăm sóc mèo.',
      'isGoing': true,
      'status': 'ongoing',
      'rating': 4.6,
      'organizer': 'Cat Lovers Community',
      'price': 'Miễn phí',
    },
    {
      'id': '6',
      'title': 'Pet Health Check-up 2024',
      'date': '15 Nov 2024',
      'time': '08:00 - 18:00',
      'location': 'Vet Hospital Saigon',
      'category': 'Sức khỏe',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 892,
      'description': 'Kiểm tra sức khỏe miễn phí cho thú cưng tại bệnh viện thú y.',
      'isGoing': true,
      'status': 'past',
      'rating': 4.8,
      'organizer': 'Vet Hospital Saigon',
      'price': 'Miễn phí',
    },
    {
      'id': '7',
      'title': 'Pet Olympiad 2024',
      'date': '10 Nov 2024',
      'time': '07:00 - 17:00',
      'location': 'Youth Park, TP HCM',
      'category': 'Thể thao',
      'image': 'lib/res/drawables/setting/tag-HL.jpg',
      'attendees': 1567,
      'description':
          'Cuộc thi thể thao cho thú cưng với các hoạt động vui nhộn và giải thưởng hấp dẫn.',
      'isGoing': true,
      'status': 'past',
      'rating': 4.9,
      'organizer': 'Pet Sports Club',
      'price': '50.000đ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('date', descending: false)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          allEvents = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
          _applyFilters();
        });
      } else {
        setState(() {
          allEvents = List.from(localEvents);
          _applyFilters();
        });
      }
    } catch (e) {
      setState(() {
        allEvents = List.from(localEvents);
        _applyFilters();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_events') ?? [];
    setState(() {
      favoriteEventIds = favorites.toSet();
    });
  }

  Future<void> _toggleFavorite(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteEventIds.contains(eventId)) {
        favoriteEventIds.remove(eventId);
      } else {
        favoriteEventIds.add(eventId);
      }
    });
    await prefs.setStringList('favorite_events', favoriteEventIds.toList());
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(allEvents);

    // Filter by status (tab)
    String status;
    switch (selectedTab) {
      case 0:
        status = 'upcoming';
        break;
      case 1:
        status = 'ongoing';
        break;
      case 2:
        status = 'past';
        break;
      default:
        status = 'upcoming';
    }
    filtered = filtered.where((event) => event['status'] == status).toList();

    // Filter by category
    if (selectedCategory != 'Tất cả') {
      filtered = filtered
          .where((event) => event['category'] == selectedCategory)
          .toList();
    }

    // Filter by location
    if (selectedLocation != 'Tất cả') {
      filtered = filtered
          .where((event) =>
              event['location'].toString().contains(selectedLocation))
          .toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((event) {
        return event['title'].toString().toLowerCase().contains(query) ||
            event['description'].toString().toLowerCase().contains(query) ||
            event['organizer'].toString().toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      filteredEvents = filtered;
    });
  }

  List<Map<String, dynamic>> get currentEvents => filteredEvents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        title: Text(
          'Sự kiện',
          style: GoogleFonts.afacad(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Badge(
                isLabelVisible: favoriteEventIds.isNotEmpty,
                label: Text('${favoriteEventIds.length}'),
                child: const Icon(Icons.favorite, color: Color(0xFF8B5CF6)),
              ),
              onPressed: _showFavorites,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEvents,
        color: const Color(0xFF8B5CF6),
        child: SafeArea(
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sự kiện...',
                    hintStyle: GoogleFonts.afacad(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  style: GoogleFonts.afacad(),
                ),
              ),

              // Filter chips
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFilterChip(
                        'Danh mục',
                        Icons.category,
                        () => _showCategoryFilter(),
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        'Hình thức',
                        Icons.location_on,
                        () => _showLocationFilter(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tabButton('Sắp tới', 0),
                    _tabButton('Đang diễn', 1),
                    _tabButton('Đã kết thúc', 2),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Events list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      )
                    : currentEvents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không có sự kiện nào',
                                  style: GoogleFonts.afacad(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: currentEvents.length,
                            itemBuilder: (context, index) {
                              return _eventCard(context, currentEvents[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8B5CF6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF8B5CF6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.afacad(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn danh mục',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.map((category) => ListTile(
                  title: Text(
                    category,
                    style: GoogleFonts.afacad(fontSize: 14),
                  ),
                  trailing: selectedCategory == category
                      ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn địa điểm',
              style: GoogleFonts.afacad(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...locations.map((location) => ListTile(
                  title: Text(
                    location,
                    style: GoogleFonts.afacad(fontSize: 14),
                  ),
                  trailing: selectedLocation == location
                      ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                      : null,
                  onTap: () {
                    setState(() {
                      selectedLocation = location;
                      _applyFilters();
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showFavorites() {
    final favoriteEvents = allEvents
        .where((event) => favoriteEventIds.contains(event['id']))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sự kiện yêu thích',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${favoriteEvents.length}',
                      style: GoogleFonts.afacad(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: favoriteEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có sự kiện yêu thích',
                            style: GoogleFonts.afacad(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: favoriteEvents.length,
                      itemBuilder: (context, index) {
                        return _eventCard(context, favoriteEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          _applyFilters();
        });
      },
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _eventCard(BuildContext context, Map<String, dynamic> event) {
    final eventId = event['id'].toString();
    final isFavorite = favoriteEventIds.contains(eventId);
    final rating = event['rating'] ?? 0.0;

    return GestureDetector(
      onTap: () {
        _showEventDetail(context, event);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: DecorationImage(
                      image: AssetImage(event['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event['category'] ?? 'Sự kiện',
                      style: GoogleFonts.afacad(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(eventId),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                if (event['isGoing'] == true)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'Đã tham gia',
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event['title'],
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 12, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: GoogleFonts.afacad(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Organizer
                  if (event['organizer'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.business, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event['organizer'],
                              style: GoogleFonts.afacad(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Date and time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 12, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: GoogleFonts.afacad(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time,
                          size: 12, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['time'],
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 12, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['location'],
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Footer - Attendees and button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${event['attendees']} người',
                            style: GoogleFonts.afacad(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              event['price'] ?? 'Miễn phí',
                              style: GoogleFonts.afacad(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (event['isGoing'] != true)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            setState(() {
                              event['isGoing'] = true;
                              event['attendees']++;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bạn đã đăng ký sự kiện này!',
                                  style: GoogleFonts.afacad(),
                                ),
                                backgroundColor: const Color(0xFF8B5CF6),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'Tham gia',
                            style: GoogleFonts.afacad(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
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

  void _showEventDetail(BuildContext context, Map<String, dynamic> event) {
    final eventId = event['id'].toString();
    final isFavorite = favoriteEventIds.contains(eventId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
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
                  const SizedBox(height: 20),

                  // Title and favorite button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event['title'],
                          style: GoogleFonts.afacad(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          _toggleFavorite(eventId);
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Image
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(event['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category and rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event['category'] ?? 'Sự kiện',
                          style: GoogleFonts.afacad(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${event['rating'] ?? 0.0}',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event['price'] ?? 'Miễn phí',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Event details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (event['organizer'] != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.business,
                                  color: Color(0xFF8B5CF6), size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ban tổ chức',
                                      style: GoogleFonts.afacad(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      event['organizer'],
                                      style: GoogleFonts.afacad(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                color: Color(0xFF8B5CF6), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ngày',
                                    style: GoogleFonts.afacad(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    event['date'],
                                    style: GoogleFonts.afacad(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Color(0xFF8B5CF6), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thời gian',
                                    style: GoogleFonts.afacad(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    event['time'],
                                    style: GoogleFonts.afacad(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                color: Color(0xFF8B5CF6), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Địa điểm',
                                    style: GoogleFonts.afacad(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    event['location'],
                                    style: GoogleFonts.afacad(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'Chi tiết sự kiện',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event['description'],
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Attendees count
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 12),
                        Text(
                          '${event['attendees']} người đã tham gia',
                          style: GoogleFonts.afacad(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: event['isGoing'] == true
                            ? Colors.grey
                            : const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: event['isGoing'] == true
                          ? null
                          : () {
                              setState(() {
                                event['isGoing'] = true;
                                event['attendees']++;
                              });
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bạn đã đăng ký sự kiện thành công!',
                                    style: GoogleFonts.afacad(),
                                  ),
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                      child: Text(
                        event['isGoing'] == true
                            ? 'Đã đăng ký'
                            : 'Đăng ký tham gia',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
