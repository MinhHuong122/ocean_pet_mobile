import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/EventsService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsScreenNew extends StatefulWidget {
  const EventsScreenNew({super.key});

  @override
  State<EventsScreenNew> createState() => _EventsScreenNewState();
}

class _EventsScreenNewState extends State<EventsScreenNew> {
  int selectedTab = 0; // 0: Sắp tới, 1: Đang diễn ra, 2: Đã kết thúc

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
            child: GestureDetector(
              onTap: () => _showCreateEventDialog(),
              child: Icon(Icons.add_circle, color: Color(0xFF8B5CF6), size: 28),
            ),
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
                    _tabButton('Đang diễn ra', 1),
                    _tabButton('Đã kết thúc', 2),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Events list - Real-time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _getEventsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final events = snapshot.data ?? [];

                        if (events.isEmpty) {
                          return Center(
                            child: Text(
                              'Chưa có sự kiện nào',
                              style: GoogleFonts.afacad(color: Colors.grey),
                            ),
                          );
                        }

                        return Column(
                          children: events
                              .map((event) => _eventCard(context, event))
                              .toList(),
                        );
                      },
                    ),
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

  Stream<List<Map<String, dynamic>>> _getEventsStream() {
    switch (selectedTab) {
      case 0:
        return EventsService.getEventsByType('upcoming');
      case 1:
        return EventsService.getEventsByType('ongoing');
      case 2:
        return EventsService.getEventsByType('past');
      default:
        return EventsService.getEventsByType('upcoming');
    }
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
      onTap: () => _showEventDetail(context, event),
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
                image: event['image_url'] != null
                    ? DecorationImage(
                        image: NetworkImage(event['image_url']),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: event['image_url'] == null ? Colors.grey[200] : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${event['attendees_count'] ?? 0} người',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.white,
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
                  Text(
                    event['title'] ?? 'Untitled Event',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22223B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        _formatDate(event['start_date']),
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event['location'] ?? 'No location',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await EventsService.rsvpEvent(event['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã tham gia sự kiện!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B5CF6),
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Text(
                        'Tham gia',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                  event['title'] ?? 'Untitled Event',
                  style: GoogleFonts.afacad(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.people, color: Color(0xFF8B5CF6)),
                          SizedBox(height: 4),
                          Text(
                            '${event['attendees_count'] ?? 0}',
                            style: GoogleFonts.afacad(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Người',
                            style: GoogleFonts.afacad(fontSize: 10),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                          SizedBox(height: 4),
                          Text(
                            _formatDate(event['start_date']),
                            style: GoogleFonts.afacad(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF8B5CF6)),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 80,
                            child: Text(
                              event['location'] ?? 'N/A',
                              style: GoogleFonts.afacad(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                  'Mô tả',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22223B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  event['description'] ?? 'No description',
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 16),

                // Attendees count
                Text(
                  'Người tham gia: ${event['attendees_count'] ?? 0}',
                  style: GoogleFonts.afacad(
                    fontSize: 13,
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

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime? selectedDate;
    String selectedType = 'upcoming';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Tạo sự kiện',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: 'Tên sự kiện',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Mô tả sự kiện',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 3,
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: 'Địa điểm',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: GoogleFonts.afacad(),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Loại sự kiện',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: ['upcoming', 'ongoing', 'past']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type == 'upcoming'
                                  ? 'Sắp tới'
                                  : type == 'ongoing'
                                      ? 'Đang diễn ra'
                                      : 'Đã kết thúc',
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await EventsService.createEvent(
                    title: titleController.text,
                    description: descriptionController.text,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(Duration(hours: 2)),
                    location: locationController.text,
                    eventType: selectedType,
                  );

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sự kiện đã được tạo!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B5CF6),
              ),
              child: Text('Tạo', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      final datetime = date.toDate();
      return '${datetime.day}/${datetime.month}/${datetime.year}';
    } else if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }
}
