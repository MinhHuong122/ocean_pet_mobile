// lib/screens/trash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrashScreen extends StatefulWidget {
  final List<Map<String, dynamic>> trashedEntries;
  final Function(Map<String, dynamic>) onRestore;
  final Function(Map<String, dynamic>) onDeletePermanently;

  const TrashScreen({
    super.key,
    required this.trashedEntries,
    required this.onRestore,
    required this.onDeletePermanently,
  });

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Thùng rác',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: widget.trashedEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thùng rác trống',
                    style: GoogleFonts.afacad(
                      fontSize: 20,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Các mục đã xóa sẽ được lưu trong 30 ngày',
                    style: GoogleFonts.afacad(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.trashedEntries.length,
              itemBuilder: (context, index) {
                final entry = widget.trashedEntries[index];
                final deletedAt = DateTime.parse(entry['deletedAt']);
                final daysLeft =
                    30 - DateTime.now().difference(deletedAt).inDays;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: entry['color'].withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        entry['icon'],
                        color: entry['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      entry['title'],
                      style: GoogleFonts.afacad(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          entry['description'],
                          style: GoogleFonts.afacad(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Xóa sau $daysLeft ngày',
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.red[300],
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'restore') {
                          _confirmRestore(entry);
                        } else if (value == 'delete') {
                          _confirmDeletePermanently(entry);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              const Icon(Icons.restore,
                                  color: Color(0xFF66BB6A), size: 20),
                              const SizedBox(width: 12),
                              Text('Khôi phục', style: GoogleFonts.afacad()),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_forever,
                                  color: Color(0xFFEF5350), size: 20),
                              const SizedBox(width: 12),
                              Text('Xóa vĩnh viễn',
                                  style: GoogleFonts.afacad(
                                      color: const Color(0xFFEF5350))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmRestore(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Khôi phục hoạt động',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có muốn khôi phục "${entry['title']}"?',
          style: GoogleFonts.afacad(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              widget.onRestore(entry);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã khôi phục hoạt động'),
                  backgroundColor: Color(0xFF66BB6A),
                ),
              );
            },
            child: Text('Khôi phục',
                style: GoogleFonts.afacad(color: const Color(0xFF66BB6A))),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePermanently(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xóa vĩnh viễn',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Text(
          'Bạn có chắc chắn muốn xóa vĩnh viễn "${entry['title']}"? Hành động này không thể hoàn tác.',
          style: GoogleFonts.afacad(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              widget.onDeletePermanently(entry);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa vĩnh viễn'),
                  backgroundColor: Color(0xFFEF5350),
                ),
              );
            },
            child: Text('Xóa',
                style: GoogleFonts.afacad(color: const Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }
}
