// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';
import './trash_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DiaryDetailScreen extends StatefulWidget {
  final Map<String, dynamic> entry;
  final Function(Map<String, dynamic>) onUpdate;
  final Function(String) onDelete;
  const DiaryDetailScreen({
    super.key,
    required this.entry,
    required this.onUpdate,
    required this.onDelete,
  });
  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  List<String> folders = ['Gia đình', 'Công việc', 'Du lịch', 'Cá nhân'];
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry['title']);
    _descriptionController =
        TextEditingController(text: widget.entry['description']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.entry['title'] = _titleController.text;
    widget.entry['description'] = _descriptionController.text;
    widget.onUpdate(widget.entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thay đổi'),
        backgroundColor: Color(0xFF66BB6A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = widget.entry['bgColor'] ?? Colors.white;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chi tiết hoạt động',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF22223B)),
            onSelected: (value) {
              switch (value) {
                case 'change_tag':
                  _showChangeTagDialog();
                  break;
                case 'add_image':
                  _addImage();
                  break;
                case 'change_color':
                  _showColorPicker();
                  break;
                case 'set_password':
                  _showSetPasswordDialog();
                  break;
                case 'add_to_folder':
                  _showAddToFolderDialog();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_tag',
                child: Row(
                  children: [
                    const Icon(Icons.label, color: Color(0xFF8E97FD), size: 20),
                    const SizedBox(width: 12),
                    Text('Đổi tag', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_image',
                child: Row(
                  children: [
                    const Icon(Icons.image, color: Color(0xFF8E97FD), size: 20),
                    const SizedBox(width: 12),
                    Text('Thêm hình', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_color',
                child: Row(
                  children: [
                    const Icon(Icons.palette,
                        color: Color(0xFF8E97FD), size: 20),
                    const SizedBox(width: 12),
                    Text('Đổi màu nền', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'set_password',
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Color(0xFF8E97FD), size: 20),
                    const SizedBox(width: 12),
                    Text('Đặt mật khẩu', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_to_folder',
                child: Row(
                  children: [
                    const Icon(Icons.folder,
                        color: Color(0xFF8E97FD), size: 20),
                    const SizedBox(width: 12),
                    Text('Thêm vào thư mục', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete,
                        color: Color(0xFFEF5350), size: 20),
                    const SizedBox(width: 12),
                    Text('XÃ³a',
                        style:
                            GoogleFonts.afacad(color: const Color(0xFFEF5350))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.entry['color'].withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.entry['icon'],
                      color: widget.entry['color'], size: 28),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.entry['category'],
                  style: GoogleFonts.afacad(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.entry['color'],
                  ),
                ),
                if (widget.entry['hasPassword'] == true) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.lock, size: 16, color: Colors.grey),
                ],
                if (widget.entry['folder'] != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.folder, size: 12, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          widget.entry['folder'],
                          style: GoogleFonts.afacad(
                              fontSize: 11, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onDoubleTap: () {
                // Cho phÃ©p edit title báº±ng double tap
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Chá»‰nh sá»­a tiÃªu Ä‘á»',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    content: TextField(
                      controller: _titleController,
                      style: GoogleFonts.afacad(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Há»§y',
                            style: GoogleFonts.afacad(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _saveChanges();
                          });
                          Navigator.pop(context);
                        },
                        child: Text('LÆ°u',
                            style: GoogleFonts.afacad(
                                color: const Color(0xFF8E97FD))),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                _titleController.text,
                style: GoogleFonts.afacad(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${widget.entry['time']} â€¢ ${widget.entry['date']}',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onDoubleTap: () {
                // Cho phÃ©p edit description báº±ng double tap
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Chá»‰nh sá»­a mÃ´ táº£',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    content: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      style: GoogleFonts.afacad(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Há»§y',
                            style: GoogleFonts.afacad(color: Colors.grey)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _saveChanges();
                          });
                          Navigator.pop(context);
                        },
                        child: Text('LÆ°u',
                            style: GoogleFonts.afacad(
                                color: const Color(0xFF8E97FD))),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                _descriptionController.text,
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            if (widget.entry['images'] != null &&
                widget.entry['images'].isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (widget.entry['images'] as List<String>).map((imagePath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(imagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showChangeTagDialog() {
    final categories = [
      'Ä‚n uá»‘ng',
      'Sá»©c khá»e',
      'Vui chÆ¡i',
      'Táº¯m rá»­a'
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Äá»•i tag',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((cat) {
            return ListTile(
              title: Text(cat, style: GoogleFonts.afacad()),
              onTap: () {
                setState(() {
                  widget.entry['category'] = cat;
                  widget.entry['color'] = _getCategoryColor(cat);
                  widget.entry['icon'] = _getCategoryIcon(cat);
                  _saveChanges();
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _addImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        widget.entry['images'] ??= [];
        widget.entry['images'].add(image.path);
        _saveChanges();
      });
    }
  }

  void _showColorPicker() {
    final colors = [
      Colors.white,
      const Color(0xFFFFF9E6),
      const Color(0xFFFFE6E6),
      const Color(0xFFE6F7FF),
      const Color(0xFFF0E6FF),
      const Color(0xFFE6FFE6),
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chá»n mÃ u ná»n',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.entry['bgColor'] = color;
                  _saveChanges();
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSetPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Äáº·t máº­t kháº©u',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Máº­t kháº©u',
            labelStyle: GoogleFonts.afacad(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Há»§y', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                widget.entry['password'] = passwordController.text;
                widget.entry['hasPassword'] = true;
                _saveChanges();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ÄÃ£ Ä‘áº·t máº­t kháº©u')),
              );
            },
            child: Text('LÆ°u',
                style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }

  void _showAddToFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ThÃªm vÃ o thÆ° má»¥c',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: folders.map((folder) {
            return ListTile(
              leading: const Icon(Icons.folder, color: Color(0xFF8E97FD)),
              title: Text(folder, style: GoogleFonts.afacad()),
              onTap: () {
                setState(() {
                  widget.entry['folder'] = folder;
                  _saveChanges();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('ÄÃ£ thÃªm vÃ o thÆ° má»¥c "$folder"')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('XÃ³a hoáº¡t Ä‘á»™ng',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Text(
          'Hoáº¡t Ä‘á»™ng sáº½ Ä‘Æ°á»£c chuyá»ƒn vÃ o thÃ¹ng rÃ¡c vÃ  lÆ°u trá»¯ trong 30 ngÃ y.',
          style: GoogleFonts.afacad(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Há»§y', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              widget.entry['deletedAt'] = DateTime.now().toIso8601String();
              widget.onDelete(widget.entry['id']);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ÄÃ£ chuyá»ƒn vÃ o thÃ¹ng rÃ¡c'),
                  backgroundColor: Color(0xFFEF5350),
                ),
              );
            },
            child: Text('XÃ³a',
                style: GoogleFonts.afacad(color: const Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Ä‚n uá»‘ng':
        return Icons.restaurant;
      case 'Sá»©c khá»e':
        return Icons.medical_services;
      case 'Vui chÆ¡i':
        return Icons.sports_soccer;
      case 'Táº¯m rá»­a':
        return Icons.bathroom;
      default:
        return Icons.event_note;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ä‚n uá»‘ng':
        return const Color(0xFFFFB74D);
      case 'Sá»©c khá»e':
        return const Color(0xFFEF5350);
      case 'Vui chÆ¡i':
        return const Color(0xFF66BB6A);
      case 'Táº¯m rá»­a':
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFF8E97FD);
    }
  }
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String selectedFilter = 'Táº¥t cáº£';
  List<String> folders = [
    'Gia Ä‘Ã¬nh',
    'CÃ´ng viá»‡c',
    'Du lá»‹ch',
    'CÃ¡ nhÃ¢n'
  ];
  List<Map<String, dynamic>> trashedEntries = [];
  final List<String> filters = [
    'Táº¥t cáº£',
    'Ä‚n uá»‘ng',
    'Sá»©c khá»e',
    'Vui chÆ¡i',
    'Táº¯m rá»­a'
  ];
  List<Map<String, dynamic>> diaryEntries = [
    {
      'id': '1',
      'title': 'Mochi Äƒn sÃ¡ng',
      'time': '8:00 AM',
      'date': '17/09/2025',
      'category': 'Ä‚n uá»‘ng',
      'description': 'Mochi Ä‘Ã£ Äƒn 100g thá»©c Äƒn khÃ´ vÃ  uá»‘ng nÆ°á»›c',
      'icon': Icons.restaurant,
      'color': Color(0xFFFFB74D),
    },
    {
      'id': '2',
      'title': 'Táº¯m cho Mochi',
      'time': '2:00 PM',
      'date': '17/09/2025',
      'category': 'Táº¯m rá»­a',
      'description': 'Táº¯m vÃ  cháº£i lÃ´ng cho Mochi',
      'icon': Icons.bathroom,
      'color': Color(0xFF64B5F6),
    },
    {
      'id': '3',
      'title': 'KhÃ¡m sá»©c khá»e Ä‘á»‹nh ká»³',
      'time': '10:00 AM',
      'date': '15/09/2025',
      'category': 'Sá»©c khá»e',
      'description': 'Kiá»ƒm tra sá»©c khá»e tá»•ng quÃ¡t táº¡i phÃ²ng khÃ¡m',
      'icon': Icons.medical_services,
      'color': Color(0xFFEF5350),
    },
    {
      'id': '4',
      'title': 'ChÆ¡i Ä‘Ã¹a ngoÃ i trá»i',
      'time': '5:00 PM',
      'date': '14/09/2025',
      'category': 'Vui chÆ¡i',
      'description': 'Mochi chÆ¡i vá»›i bÃ³ng vÃ  cháº¡y nháº£y 30 phÃºt',
      'icon': Icons.sports_soccer,
      'color': Color(0xFF66BB6A),
    },
    {
      'id': '5',
      'title': 'Uá»‘ng thuá»‘c dá»‹ á»©ng',
      'time': '9:00 AM',
      'date': '13/09/2025',
      'category': 'Sá»©c khá»e',
      'description': 'Cho Mochi uá»‘ng thuá»‘c theo Ä‘Æ¡n bÃ¡c sÄ©',
      'icon': Icons.medication,
      'color': Color(0xFFEF5350),
    },
  ];
  void _moveToTrash(String entryId) {
    final entryIndex = diaryEntries.indexWhere((e) => e['id'] == entryId);
    if (entryIndex != -1) {
      final entry = diaryEntries[entryIndex];
      entry['deletedAt'] = DateTime.now().toIso8601String();
      setState(() {
        trashedEntries.add(entry);
        diaryEntries.removeAt(entryIndex);
      });
    }
  }

  void _updateEntry(Map<String, dynamic> updatedEntry) {
    final index = diaryEntries.indexWhere((e) => e['id'] == updatedEntry['id']);
    if (index != -1) {
      setState(() {
        diaryEntries[index] = updatedEntry;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEntries = selectedFilter == 'Táº¥t cáº£'
        ? diaryEntries
        : diaryEntries
            .where((entry) => entry['category'] == selectedFilter)
            .toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF22223B)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Nhật ký gần đây',
          style: GoogleFonts.afacad(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF22223B)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.only(
                  top: 16, left: 18, right: 18, bottom: 0),
              child: SizedBox(
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
            ),
            // Diary entries grid
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
                  : GridView.builder(
                      padding: const EdgeInsets.all(18.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = filteredEntries[index];
                        return _buildDiaryGridCard(entry, onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DiaryDetailScreen(
                                entry: entry,
                                onUpdate: _updateEntry,
                                onDelete: _moveToTrash,
                              ),
                            ),
                          );
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEntryDialog();
        },
        backgroundColor: const Color(0xFF8E97FD),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 2,
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF8E97FD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.book, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'Nhật ký',
                    style: GoogleFonts.afacad(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading:
                  const Icon(Icons.create_new_folder, color: Color(0xFF8E97FD)),
              title: Text('Tạo thư mục mới',
                  style: GoogleFonts.afacad(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
              title: Text('Thùng rác', style: GoogleFonts.afacad(fontSize: 14)),
              trailing: trashedEntries.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${trashedEntries.length}',
                        style: GoogleFonts.afacad(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrashScreen(
                      trashedEntries: trashedEntries,
                      onRestore: (entry) {
                        setState(() {
                          trashedEntries.remove(entry);
                          entry.remove('deletedAt');
                          diaryEntries.add(entry);
                        });
                      },
                      onDeletePermanently: (entry) {
                        setState(() {
                          trashedEntries.remove(entry);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Thư mục',
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...folders.map((folder) {
              return ListTile(
                leading: const Icon(Icons.folder,
                    color: Color(0xFF8E97FD), size: 20),
                title: Text(folder, style: GoogleFonts.afacad(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lọc theo thư mục
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showCreateFolderDialog() {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Táº¡o thÆ° má»¥c má»›i',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: folderController,
          decoration: InputDecoration(
            labelText: 'TÃªn thÆ° má»¥c',
            labelStyle: GoogleFonts.afacad(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: GoogleFonts.afacad(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Há»§y', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (folderController.text.isNotEmpty) {
                setState(() {
                  folders.add(folderController.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'ÄÃ£ táº¡o thÆ° má»¥c "${folderController.text}"')),
                );
              }
            },
            child: Text('Táº¡o',
                style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryGridCard(Map<String, dynamic> entry,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showEntryOptions(entry),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: entry['color'].withOpacity(0.13),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
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
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry['color'].withOpacity(0.13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry['category'],
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: entry['color'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry['title'],
              style: GoogleFonts.afacad(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              entry['description'],
              style: GoogleFonts.afacad(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 13,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(
                  '${entry['time']} â€¢ ${entry['date']}',
                  style: GoogleFonts.afacad(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
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
              title: Text('Chá»‰nh sá»­a hoáº¡t Ä‘á»™ng',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'TiÃªu Ä‘á»',
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
                        labelText: 'MÃ´ táº£',
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
                        labelText: 'Danh má»¥c',
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
                  child: Text('Há»§y',
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
                        content: Text('ÄÃ£ cáº­p nháº­t hoáº¡t Ä‘á»™ng'),
                        backgroundColor: Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('LÆ°u',
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
    String selectedCategory = 'Ä‚n uá»‘ng';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('ThÃªm hoáº¡t Ä‘á»™ng má»›i',
                  style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'TiÃªu Ä‘á»',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'VD: Mochi Äƒn sÃ¡ng',
                        hintStyle: GoogleFonts.afacad(color: Colors.grey),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'MÃ´ táº£',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'MÃ´ táº£ chi tiáº¿t hoáº¡t Ä‘á»™ng...',
                        hintStyle: GoogleFonts.afacad(color: Colors.grey),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Danh má»¥c',
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
                  child: Text('Há»§y',
                      style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty ||
                        descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Vui lÃ²ng Ä‘iá»n Ä‘áº§y Ä‘á»§ thÃ´ng tin'),
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
                        content: Text('ÄÃ£ thÃªm hoáº¡t Ä‘á»™ng má»›i'),
                        backgroundColor: Color(0xFF66BB6A),
                      ),
                    );
                  },
                  child: Text('ThÃªm',
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
      case 'Ä‚n uá»‘ng':
        return Icons.restaurant;
      case 'Sá»©c khá»e':
        return Icons.medical_services;
      case 'Vui chÆ¡i':
        return Icons.sports_soccer;
      case 'Táº¯m rá»­a':
        return Icons.bathroom;
      default:
        return Icons.event_note;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ä‚n uá»‘ng':
        return const Color(0xFFFFB74D);
      case 'Sá»©c khá»e':
        return const Color(0xFFEF5350);
      case 'Vui chÆ¡i':
        return const Color(0xFF66BB6A);
      case 'Táº¯m rá»­a':
        return const Color(0xFF64B5F6);
      default:
        return const Color(0xFF8E97FD);
    }
  }
}
