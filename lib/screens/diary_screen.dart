// lib/screens/diary_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';
import './trash_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<String> folders = [];

  bool _editingTitle = false;
  bool _editingDescription = false;
  late FocusNode _titleFocus;
  late FocusNode _descFocus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry['title']);
    _descriptionController =
        TextEditingController(text: widget.entry['description']);
    _titleFocus = FocusNode();
    _descFocus = FocusNode();
    _loadFoldersFromPrefs();
  }

  Future<void> _loadFoldersFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final petFolders = prefs.getStringList('selected_pets') ?? [];
    setState(() {
      folders = petFolders.isNotEmpty ? petFolders : ['Chưa chọn thú cưng'];
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
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
                    Text('Xóa',
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
            _editingTitle
                ? TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: GoogleFonts.afacad(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _editingTitle = false;
                        _saveChanges();
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _editingTitle = false;
                        _saveChanges();
                      });
                    },
                    autofocus: true,
                    onTapOutside: (_) {
                      setState(() {
                        _editingTitle = false;
                        _saveChanges();
                      });
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingTitle = true;
                        FocusScope.of(context).requestFocus(_titleFocus);
                      });
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
                  '${widget.entry['time']} • ${widget.entry['date']}',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _editingDescription
                ? TextField(
                    controller: _descriptionController,
                    focusNode: _descFocus,
                    maxLines: 5,
                    style: GoogleFonts.afacad(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _editingDescription = false;
                        _saveChanges();
                      });
                    },
                    onEditingComplete: () {
                      setState(() {
                        _editingDescription = false;
                        _saveChanges();
                      });
                    },
                    autofocus: true,
                    onTapOutside: (_) {
                      setState(() {
                        _editingDescription = false;
                        _saveChanges();
                      });
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingDescription = true;
                        FocusScope.of(context).requestFocus(_descFocus);
                      });
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
    final categories = ['Ăn uống', 'Sức khỏe', 'Vui chơi', 'Tắm rửa'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Đổi nhãn',
            style: GoogleFonts.afacad(
                fontWeight: FontWeight.bold, color: Colors.black)),
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
        backgroundColor: Colors.white,
        title: Text('Chọn màu nền',
            style: GoogleFonts.afacad(
                fontWeight: FontWeight.bold, color: Colors.black)),
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
        backgroundColor: Colors.white,
        title: Text('Đặt mật khẩu',
            style: GoogleFonts.afacad(
                fontWeight: FontWeight.bold, color: Colors.black)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            labelStyle: GoogleFonts.afacad(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
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
                const SnackBar(content: Text('Đã đặt mật khẩu')),
              );
            },
            child: Text('Lưu',
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
        backgroundColor: Colors.white,
        title: Text('Thêm vào thư mục',
            style: GoogleFonts.afacad(
                fontWeight: FontWeight.bold, color: Colors.black)),
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
                  SnackBar(content: Text('Đã thêm vào thư mục "$folder"')),
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
        title: Text('Xóa hoạt động',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Text(
          'Hoạt động sẽ được chuyển vào thùng rác và lưu trữ trong 30 ngày.',
          style: GoogleFonts.afacad(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              widget.entry['deletedAt'] = DateTime.now().toIso8601String();
              widget.onDelete(widget.entry['id']);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chuyển vào thùng rác'),
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

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String selectedFilter = 'Tất cả';
  // Update folders to represent pet types
  List<String> folders = ['Mèo', 'Chó', 'Chuột', 'Chim', 'Cá', 'Thỏ', 'Rùa'];
  List<Map<String, dynamic>> trashedEntries = [];
  final List<String> filters = [
    'Tất cả',
    'Ăn uống',
    'Sức khỏe',
    'Vui chơi',
    'Tắm rửa'
  ];
  String searchQuery = '';
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
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

  void _showCreateFolderDialog() {
    final folderController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Tạo thú nuôi mới',
              style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          content: TextField(
            controller: folderController,
            decoration: InputDecoration(
              labelText: 'Tên thú nuôi',
              labelStyle: GoogleFonts.afacad(),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: 'VD: Sóc, Nhím, ...',
              hintStyle: GoogleFonts.afacad(color: Colors.grey),
            ),
            style: GoogleFonts.afacad(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final newFolder = folderController.text.trim();
                if (newFolder.isNotEmpty && !folders.contains(newFolder)) {
                  setState(() {
                    folders.add(newFolder);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm thú nuôi mới'),
                      backgroundColor: Color(0xFF66BB6A),
                    ),
                  );
                } else if (folders.contains(newFolder)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Thú nuôi đã tồn tại'),
                      backgroundColor: Color(0xFFEF5350),
                    ),
                  );
                }
              },
              child: Text('Tạo',
                  style: GoogleFonts.afacad(
                      color: Color(0xFF8E97FD), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

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
    // Apply filter and search
    List<Map<String, dynamic>> filteredEntries = selectedFilter == 'Tất cả'
        ? diaryEntries
        : diaryEntries
            .where((entry) => entry['category'] == selectedFilter)
            .toList();
    if (searchQuery.isNotEmpty) {
      filteredEntries = filteredEntries.where((entry) {
        final title = (entry['title'] ?? '').toString().toLowerCase();
        final desc = (entry['description'] ?? '').toString().toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query) || desc.contains(query);
      }).toList();
    }
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
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.afacad(
                  color: const Color(0xFF22223B),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm hoạt động...',
                  hintStyle: GoogleFonts.afacad(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                onSubmitted: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              )
            : Text(
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
            icon: Icon(
              isSearching ? Icons.check : Icons.search,
              color: const Color(0xFF22223B),
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  // Confirm search
                  isSearching = false;
                } else {
                  // Start searching
                  isSearching = true;
                  searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF22223B)),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = '';
                  _searchController.clear();
                });
              },
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
      width: MediaQuery.of(context).size.width * 0.6,
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
              title: Text('Tạo thú nuôi mới',
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
                'Thú nuôi',
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ...folders.map((folder) {
              return ListTile(
                leading:
                    const Icon(Icons.pets, color: Color(0xFF8E97FD), size: 20),
                title: Text(folder, style: GoogleFonts.afacad(fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Lọc theo thú nuôi
                },
              );
            }).toList(),
          ],
        ),
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
                  '${entry['time']} • ${entry['date']}',
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
          backgroundColor: Colors.white,
          title: Text('Xóa hoạt động',
              style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold, color: Colors.black)),
          content: Text(
            'Bạn có chắc chắn muốn xóa "${entry['title']}"?',
            style: GoogleFonts.afacad(color: Colors.black),
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
                      initialValue: selectedCategory,
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
                      initialValue: selectedCategory,
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
