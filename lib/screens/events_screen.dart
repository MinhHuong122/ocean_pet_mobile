import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  int selectedTab = 0; // 0: Sắp tới, 1: Đang diễn ra, 2: Đã kết thúc

  final List<Map<String, dynamic>> upcomingEvents = [
    {
      'title': 'Hội chợ chó cỏn cỏn',
      'date': '20 Nov 2024',
      'time': '09:00 - 17:00',
      'location': 'Tao Đàn Park, TP HCM',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 324,
      'description':
          'Hội chợ thú cưng lớn nhất năm với hơn 100 gian hàng bán thú cưng, phụ kiện, và dịch vụ chám sóc.',
      'isGoing': false,
    },
    {
      'title': 'Khoá huấn luyện chó miễn phí',
      'date': '22 Nov 2024',
      'time': '14:00 - 16:00',
      'location': 'Bark Park, Quận 1',
      'image': 'lib/res/drawables/setting/tag-HL.jpg',
      'attendees': 58,
      'description':
          'Các trainer chuyên nghiệp sẽ hướng dẫn cách huấn luyện chó cơ bản miễn phí.',
      'isGoing': false,
    },
    {
      'title': 'Pet Fashion Show 2024',
      'date': '25 Nov 2024',
      'time': '18:00 - 20:30',
      'location': 'Diamond Plaza, TP HCM',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'attendees': 512,
      'description':
          'Sàn diễn thời trang cho thú cưng với các bộ trang phục độc đáo và kỳ lạ.',
      'isGoing': false,
    },
  ];

  final List<Map<String, dynamic>> ongoingEvents = [
    {
      'title': 'Chương trình nhận nuôi thú cưng',
      'date': 'Đang diễn ra',
      'time': 'Hàng tuần',
      'location': 'Animal Rescue Center',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 1250,
      'description':
          'Chương trình giúp các bạn tìm được những chú thú cưng yêu thương để nhận nuôi.',
      'isGoing': true,
    },
    {
      'title': 'Cộng đồng yêu thích mèo',
      'date': 'Đang diễn ra',
      'time': 'Hàng tháng',
      'location': 'Online & Offline',
      'image': 'lib/res/drawables/setting/tag-VN.png',
      'attendees': 3400,
      'description':
          'Cộng đồng những người yêu mèo chia sẻ kinh nghiệm và chăm sóc mèo.',
      'isGoing': true,
    },
  ];

  final List<Map<String, dynamic>> pastEvents = [
    {
      'title': 'Pet Health Check-up 2024',
      'date': '15 Nov 2024',
      'time': '08:00 - 18:00',
      'location': 'Vet Hospital Saigon',
      'image': 'lib/res/drawables/setting/tag-SK.png',
      'attendees': 892,
      'description': 'Kiểm tra sức khỏe miễn phí cho thú cưng tại bệnh viện thú y.',
      'isGoing': true,
    },
    {
      'title': 'Pet Olympiad 2024',
      'date': '10 Nov 2024',
      'time': '07:00 - 17:00',
      'location': 'Youth Park, TP HCM',
      'image': 'lib/res/drawables/setting/tag-HL.jpg',
      'attendees': 1567,
      'description':
          'Cuộc thi thể thao cho thú cưng với các hoạt động vui nhộn và giải thưởng hấp dẫn.',
      'isGoing': true,
    },
  ];

  List<Map<String, dynamic>> get currentEvents {
    switch (selectedTab) {
      case 0:
        return upcomingEvents;
      case 1:
        return ongoingEvents;
      case 2:
        return pastEvents;
      default:
        return upcomingEvents;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sự kiện',
          style: GoogleFonts.afacad(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(Icons.calendar_today, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              SizedBox(height: 20),

              // Events list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ...currentEvents
                        .map((event) => _eventCard(context, event))
                        .toList(),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
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
              margin: EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: Color(0xFF8B5CF6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _eventCard(BuildContext context, Map<String, dynamic> event) {
    return GestureDetector(
      onTap: () {
        _showEventDetail(context, event);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: AssetImage(event['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B5CF6).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event['isGoing'] ? 'Đã tham gia' : 'Chưa tham gia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event['title'],
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),

                  // Info row
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 4),
                      Text(
                        event['date'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 14, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 4),
                      Text(
                        event['time'],
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event['location'],
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Attendees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            '${event['attendees']} người tham gia',
                            style: GoogleFonts.afacad(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      if (!event['isGoing'])
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF8B5CF6),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              event['isGoing'] = true;
                              event['attendees']++;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bạn đã đăng ký sự kiện này!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text(
                            'Tham gia',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: GoogleFonts.afacad(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(event['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Event details
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text(
                            event['date'],
                            style: GoogleFonts.afacad(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text(
                            event['time'],
                            style: GoogleFonts.afacad(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event['location'],
                              style: GoogleFonts.afacad(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),

                // Description
                Text(
                  'Chi tiết sự kiện',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  event['description'],
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 16),

                // Attendees count
                Text(
                  'Tham dự (${event['attendees']} người)',
                  style: GoogleFonts.afacad(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
