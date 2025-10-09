// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String selectedFilter = 'Tất cả';

  final List<String> filters = [
    'Tất cả',
    'Ăn uống',
    'Sức khỏe',
    'Vui chơi',
    'Tắm rửa'
  ];

  List<Map<String, dynamic>> diaryEntries = [
    {
      'id': '1',
      'title': 'Mochi ăn sáng',
      'time': '8:00 AM',
      'date': '17/09/2025',
      'category': 'Ăn uống',
      'description': 'Mochi đã ăn 100g thức ăn khô và uống nước',
      'icon': Icons.restaurant,
      'color': Color(0xFFFFB74D),
    },
    {
      'id': '2',
      'title': 'Tắm cho Mochi',
      'time': '2:00 PM',
      'date': '17/09/2025',
      'category': 'Tắm rửa',
      'description': 'Tắm và chải lông cho Mochi',
      'icon': Icons.bathroom,
      'color': Color(0xFF64B5F6),
    },
    {
      'id': '3',
      'title': 'Khám sức khỏe định kỳ',
      'time': '10:00 AM',
      'date': '15/09/2025',
      'category': 'Sức khỏe',
      'description': 'Kiểm tra sức khỏe tổng quát tại phòng khám',
      'icon': Icons.medical_services,
      'color': Color(0xFFEF5350),
    },
    {
      'id': '4',
      'title': 'Chơi đùa ngoài trời',
      'time': '5:00 PM',
      'date': '14/09/2025',
      'category': 'Vui chơi',
      'description': 'Mochi chơi với bóng và chạy nhảy 30 phút',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF66BB6A),
    },
    {
      'id': '5',
      'title': 'Uống thuốc dị ứng',
      'time': '9:00 AM',
      'date': '13/09/2025',
      'category': 'Sức khỏe',
      'description': 'Cho Mochi uống thuốc theo đơn bác sĩ',
      'icon': Icons.medication,
      'color': Color(0xFFEF5350),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredEntries = selectedFilter == 'Tất cả'
        ? diaryEntries
        : diaryEntries
            .where((entry) => entry['category'] == selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Nhật Ký',
                          style: GoogleFonts.aclonica(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Image.asset(
                          'lib/res/drawables/setting/LOGO.png',
                          width: 48,
                          height: 48,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Lịch sử hoạt động',
                    style: GoogleFonts.afacad(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Theo dõi mọi hoạt động của thú cưng',
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = filter == selectedFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text(
                              filter,
                              style: GoogleFonts.afacad(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8E97FD),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF8E97FD),
                            side: BorderSide(
                              color: const Color(0xFF8E97FD),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Diary entries list
            Expanded(
              child: filteredEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_note,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có hoạt động nào',
                            style: GoogleFonts.afacad(
                              fontSize: 18,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        return _buildDiaryCard(entry);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new diary entry
          _showAddEntryDialog();
        },
        backgroundColor: const Color(0xFF8E97FD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildDiaryCard(Map<String, dynamic> entry) {
    return InkWell(
      onLongPress: () => _showEntryOptions(entry),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E97FD).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: entry['color'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry['icon'],
                  color: entry['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            entry['title'],
                            style: GoogleFonts.afacad(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: entry['color'].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry['category'],
                            style: GoogleFonts.afacad(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: entry['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry['description'],
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry['time']} • ${entry['date']}',
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            color: Colors.grey[400],
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
      ),
    );
  }

  void _showEntryOptions(Map<String, dynamic> entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF8E97FD)),
                title:
                    Text('Chỉnh sửa', style: GoogleFonts.afacad(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _showEditEntryDialog(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                title: Text('Xóa', style: GoogleFonts.afacad(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteEntry(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: Text('Hủy', style: GoogleFonts.afacad(fontSize: 16)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteEntry(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa hoạt động',
              style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${entry['title']}"?',
            style: GoogleFonts.afacad(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  diaryEntries.removeWhere((e) => e['id'] == entry['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa hoạt động'),
                    backgroundColor: Color(0xFFEF5350),
                  ),
                );
              },
              child: Text('Xóa',
                  style: GoogleFonts.afacad(
                      color: Color(0xFFEF5350), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditEntryDialog(Map<String, dynamic> entry) {
    final titleController = TextEditingController(text: entry['title']);
    final descriptionController =
        TextEditingController(text: entry['description']);
    String selectedCategory = entry['category'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Chỉnh sửa hoạt động',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: filters.skip(1).map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: GoogleFonts.afacad()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy',
                      style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      entry['title'] = titleController.text;
                      entry['description'] = descriptionController.text;
                      entry['category'] = selectedCategory;
                      entry['color'] = _getCategoryColor(selectedCategory);
                      entry['icon'] = _getCategoryIcon(selectedCategory);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã cập nhật hoạt động'),
                        backgroundColor: Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('Lưu',
                      style: GoogleFonts.afacad(
                          color: Color(0xFF8E97FD),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddEntryDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Ăn uống';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Thêm hoạt động mới',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Tiêu đề',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'VD: Mochi ăn sáng',
                        hintStyle: GoogleFonts.afacad(color: Colors.grey),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Mô tả chi tiết hoạt động...',
                        hintStyle: GoogleFonts.afacad(color: Colors.grey),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: filters.skip(1).map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter, style: GoogleFonts.afacad()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy',
                      style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                          backgroundColor: Color(0xFFEF5350),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      diaryEntries.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'title': titleController.text,
                        'time': TimeOfDay.now().format(context),
                        'date':
                            '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        'category': selectedCategory,
                        'description': descriptionController.text,
                        'icon': _getCategoryIcon(selectedCategory),
                        'color': _getCategoryColor(selectedCategory),
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm hoạt động mới'),
                        backgroundColor: Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('Thêm',
                      style: GoogleFonts.afacad(
                          color: Color(0xFF8E97FD),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Sức khỏe':
        return Icons.medical_services;
      case 'Vui chơi':
        return Icons.sports_soccer;
      case 'Tắm rửa':
        return Icons.bathroom;
      default:
        return Icons.event_note;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFFB74D);
      case 'Sức khỏe':
        return const Color(0xFFEF5350);
      case 'Vui chơi':
        return const Color(0xFF66BB6A);
      case 'Tắm rửa':
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFF8E97FD);
    }
  }
}
