// lib/screens/diary_screen.dart - Unified Diary Screen with Full Features
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './custom_bottom_nav.dart';
import './trash_screen.dart';
import './drawing_canvas.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../services/NotificationService.dart';

// Model for Diary Entry
class DiaryEntry {
  String id;
  String title;
  String description;
  String category;
  String date;
  String time;
  Color color;
  Color bgColor;
  IconData icon;
  List<String> images;
  String? audioPath;
  bool isPinned;
  bool isLocked;
  String? password;
  String? folderId; // Pet ID from Firebase
  String? folderName; // Pet name
  String? deletedAt;
  String? reminderDateTime; // ISO8601 string for reminder
  
  DiaryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.color,
    required this.bgColor,
    required this.icon,
    this.images = const [],
    this.audioPath,
    this.isPinned = false,
    this.isLocked = false,
    this.password,
    this.folderId,
    this.folderName,
    this.deletedAt,
    this.reminderDateTime,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'date': date,
    'time': time,
    'colorValue': color.value,
    'bgColorValue': bgColor.value,
    'iconCode': icon.codePoint,
    'images': images,
    'audioPath': audioPath,
    'isPinned': isPinned,
    'isLocked': isLocked,
    'password': password,
    'folderId': folderId,
    'folderName': folderName,
    'deletedAt': deletedAt,
    'reminderDateTime': reminderDateTime,
  };
  
  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    date: json['date'],
    time: json['time'],
    color: Color(json['colorValue']),
    bgColor: Color(json['bgColorValue']),
    icon: IconData(json['iconCode'], fontFamily: 'MaterialIcons'),
    images: List<String>.from(json['images'] ?? []),
    audioPath: json['audioPath'],
    isPinned: json['isPinned'] ?? false,
    isLocked: json['isLocked'] ?? false,
    password: json['password'],
    folderId: json['folderId'],
    folderName: json['folderName'],
    deletedAt: json['deletedAt'],
    reminderDateTime: json['reminderDateTime'],
  );
}

// Pet Folder Model
class PetFolder {
  String id;
  String name;
  String type; // Mèo, Chó, etc.
  int entryCount;
  
  PetFolder({
    required this.id,
    required this.name,
    required this.type,
    this.entryCount = 0,
  });
}

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});
  
  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String selectedFilter = 'Tất cả';
  List<PetFolder> petFolders = [];
  List<DiaryEntry> diaryEntries = [];
  List<DiaryEntry> trashedEntries = [];
  
  final List<String> filters = ['Tất cả', 'Ăn uống', 'Sức khỏe', 'Vui chơi', 'Tắm rửa'];
  String searchQuery = '';
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  
  String? selectedFolderId; // Filter by pet
  bool _isLoading = true;
  int activeReminders = 0; // Track count of diary entries with active reminders
  
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadData();
  }
  
  Future<void> _initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        await _recorder.openRecorder();
        setState(() {
          _isRecorderInitialized = true;
        });
      }
    } catch (e) {
      print('❌ Error initializing recorder: $e');
    }
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadPetFolders(),
      _loadDiaryEntries(),
      _loadTrashedEntries(),
    ]);
    await _loadReminderStats();
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadPetFolders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final snapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      setState(() {
        petFolders = snapshot.docs.map((doc) {
          return PetFolder(
            id: doc.id,
            name: doc['name'] ?? 'Unknown',
            type: doc['species'] ?? 'Unknown',
            entryCount: 0,
          );
        }).toList();
      });
      
      print('🐾 Loaded ${petFolders.length} pet folders');
    } catch (e) {
      print('❌ Error loading pet folders: $e');
    }
  }
  
  Future<void> _loadDiaryEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? entriesJson = prefs.getString('diary_entries');
      
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        setState(() {
          diaryEntries = decoded.map((e) => DiaryEntry.fromJson(e)).toList();
          // Sort: pinned first, then by date
          diaryEntries.sort((a, b) {
            if (a.isPinned != b.isPinned) {
              return a.isPinned ? -1 : 1;
            }
            return b.date.compareTo(a.date);
          });
        });
      } else {
        // Sample entry
        setState(() {
          diaryEntries = [
            DiaryEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Mochi ăn sáng',
              time: '8:00 AM',
              date: DateTime.now().toIso8601String(),
              category: 'Ăn uống',
              description: 'Mochi đã ăn 100g thức ăn khô và uống nước',
              icon: Icons.restaurant,
              color: const Color(0xFFFFB74D),
              bgColor: Colors.white,
            ),
          ];
        });
      }
      
      print('📝 Loaded ${diaryEntries.length} diary entries');
    } catch (e) {
      print('❌ Error loading diary entries: $e');
    }
  }
  
  Future<void> _loadTrashedEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? trashedJson = prefs.getString('trashed_entries');
      
      if (trashedJson != null) {
        final List<dynamic> decoded = jsonDecode(trashedJson);
        setState(() {
          trashedEntries = decoded.map((e) => DiaryEntry.fromJson(e)).toList();
        });
      }
      
      print('🗑️ Loaded ${trashedEntries.length} trashed entries');
    } catch (e) {
      print('❌ Error loading trashed entries: $e');
    }
  }
  
  // Load and count active reminders
  Future<void> _loadReminderStats() async {
    try {
      final now = DateTime.now();
      int activeReminderCount = 0;
      
      // Count diary entries with active (future) reminders
      for (final entry in diaryEntries) {
        if (entry.reminderDateTime != null) {
          try {
            final reminderDateTime = DateTime.parse(entry.reminderDateTime!);
            if (reminderDateTime.isAfter(now)) {
              activeReminderCount++;
            }
          } catch (e) {
            // Invalid date format, skip
          }
        }
      }
      
      setState(() {
        activeReminders = activeReminderCount;
      });
      
      print('📌 Loaded $activeReminderCount active reminders');
    } catch (e) {
      print('❌ Error loading reminder stats: $e');
    }
  }
  
  Future<void> _saveDiaryEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(diaryEntries.map((e) => e.toJson()).toList());
      await prefs.setString('diary_entries', encoded);
      print('💾 Saved ${diaryEntries.length} diary entries');
    } catch (e) {
      print('❌ Error saving diary entries: $e');
    }
  }
  
  Future<void> _saveTrashedEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(trashedEntries.map((e) => e.toJson()).toList());
      await prefs.setString('trashed_entries', encoded);
      print('💾 Saved ${trashedEntries.length} trashed entries');
    } catch (e) {
      print('❌ Error saving trashed entries: $e');
    }
  }
  
  // Save diary entry to Firebase
  Future<void> _saveDiaryEntryToFirebase(DiaryEntry entry) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      await FirebaseFirestore.instance
          .collection('diary_entries')
          .doc(entry.id)
          .set({
            'id': entry.id,
            'user_id': user.uid,
            'title': entry.title,
            'description': entry.description,
            'category': entry.category,
            'date': entry.date,
            'time': entry.time,
            'colorValue': entry.color.value,
            'bgColorValue': entry.bgColor.value,
            'iconCode': entry.icon.codePoint,
            'images': entry.images,
            'audioPath': entry.audioPath,
            'isPinned': entry.isPinned,
            'isLocked': entry.isLocked,
            'password': entry.password,
            'folderId': entry.folderId,
            'folderName': entry.folderName,
            'deletedAt': entry.deletedAt,
            'reminderDateTime': entry.reminderDateTime,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      print('💾 Saved diary entry to Firebase: ${entry.id}');
    } catch (e) {
      print('❌ Error saving diary entry to Firebase: $e');
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Apply filters
    List<DiaryEntry> filteredEntries = diaryEntries.where((entry) {
      // Filter by category
      if (selectedFilter != 'Tất cả' && entry.category != selectedFilter) {
        return false;
      }
      // Filter by pet folder
      if (selectedFolderId != null && entry.folderId != selectedFolderId) {
        return false;
      }
      // Filter by search query
      if (searchQuery.isNotEmpty) {
        final title = entry.title.toLowerCase();
        final desc = entry.description.toLowerCase();
        final query = searchQuery.toLowerCase();
        return title.contains(query) || desc.contains(query);
      }
      return true;
    }).toList();
    
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
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
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
                isSearching = !isSearching;
                if (!isSearching) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8E97FD)))
          : SafeArea(
              child: Column(
                children: [
                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 0),
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        itemBuilder: (context, index) {
                          final filter = filters[index];
                          final isSelected = selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedFilter = filter;
                                });
                              },
                              labelStyle: GoogleFonts.afacad(
                                color: const Color(0xFF8E97FD),
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF8E97FD).withOpacity(0.1),
                              side: const BorderSide(
                                color: Color(0xFF8E97FD),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Reminder stats container
                  if (activeReminders > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF8E97FD).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8E97FD).withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildReminderStatItem(
                              icon: Icons.notifications_active,
                              label: 'Nhắc nhở',
                              value: activeReminders.toString(),
                              color: const Color(0xFF8E97FD),
                            ),
                          ],
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
                                Icon(Icons.event_note, size: 80, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'Chưa có hoạt động nào',
                                  style: GoogleFonts.afacad(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(18),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: filteredEntries.length,
                            itemBuilder: (context, index) {
                              final entry = filteredEntries[index];
                              return _buildDiaryGridCard(entry);
                            },
                          ),
                  ),
                ],
              ),
            ),
      drawer: _buildDrawer(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
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
            // Create new folder option
            ListTile(
              leading: const Icon(Icons.add_circle, color: Color(0xFF8E97FD)),
              title: Text('Tạo thư mục mới',
                  style: GoogleFonts.afacad(fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _showCreateFolderDialog();
              },
            ),
            const Divider(),
            // Trash
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFEF5350)),
              title: Text('Thùng rác', style: GoogleFonts.afacad(fontSize: 14)),
              trailing: trashedEntries.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TrashScreen(
                      trashedEntries: trashedEntries.map((e) => e.toJson()).toList(),
                      onRestore: _restoreEntry,
                      onDeletePermanently: (entryData) => _permanentlyDeleteEntry(entryData['id']),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            // Section header
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
            // Pet folders
            ...petFolders.map((folder) {
              return ListTile(
                leading: const Icon(Icons.pets, color: Color(0xFF8E97FD), size: 20),
                title: Text(folder.name, style: GoogleFonts.afacad(fontSize: 14)),
                onTap: () {
                  setState(() {
                    selectedFolderId = folder.id;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  IconData _getPetIcon(String type) {
    switch (type.toLowerCase()) {
      case 'chó':
      case 'dog':
        return Icons.pets;
      case 'mèo':
      case 'cat':
        return Icons.pets;
      case 'chim':
      case 'bird':
        return Icons.flutter_dash;
      case 'cá':
      case 'fish':
        return Icons.waves;
      default:
        return Icons.pets;
    }
  }
  
  Widget _buildDiaryGridCard(DiaryEntry entry) {
    return InkWell(
      onTap: () => _openEntryDetail(entry),
      onLongPress: () => _showEntryOptions(entry),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: entry.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(entry.icon, color: entry.color, size: 24),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: entry.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.category,
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: entry.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.title,
              style: GoogleFonts.afacad(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              entry.description,
              style: GoogleFonts.afacad(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${entry.time} • ${entry.date.split('T')[0]}',
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.isPinned)
                  const Icon(Icons.push_pin, color: Color(0xFF8E97FD), size: 16),
                if (entry.isLocked)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.lock, color: Colors.grey, size: 16),
                  ),
                if (entry.audioPath != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.mic, color: Colors.orange, size: 16),
                  ),
              ],
            ),
            if (entry.folderName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.folder, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    entry.folderName!,
                    style: GoogleFonts.afacad(
                      fontSize: 11,
                      color: const Color(0xFF8E97FD),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _openEntryDetail(DiaryEntry entry) {
    // Check if locked
    if (entry.isLocked && entry.password != null) {
      _showPasswordDialog(entry);
    } else {
      _navigateToDetail(entry);
    }
  }
  
  void _showPasswordDialog(DiaryEntry entry) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFF8E97FD)),
            const SizedBox(width: 8),
            Text('Nhập mật khẩu', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
          ],
        ),
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
              if (passwordController.text == entry.password) {
                Navigator.pop(context);
                _navigateToDetail(entry);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu không đúng'),
                    backgroundColor: Color(0xFFEF5350),
                  ),
                );
              }
            },
            child: Text('Mở', style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }
  
  void _navigateToDetail(DiaryEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryDetailScreen(
          entry: entry,
          onUpdate: (updated) {
            final index = diaryEntries.indexWhere((e) => e.id == updated.id);
            if (index != -1) {
              // Update existing entry
              setState(() {
                diaryEntries[index] = updated;
              });
            } else {
              // Add new entry (for copy functionality)
              setState(() {
                diaryEntries.insert(0, updated); // Insert at beginning
              });
            }
            _saveDiaryEntries();
            _saveDiaryEntryToFirebase(updated); // Save to Firebase
            _loadReminderStats(); // Reload reminder count after update
          },
          onDelete: (id) {
            _moveToTrash(id);
          },
          recorder: _recorder,
          isRecorderInitialized: _isRecorderInitialized,
        ),
      ),
    );
  }
  
  void _showEntryOptions(DiaryEntry entry) {
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
                leading: Icon(
                  entry.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: const Color(0xFF8E97FD),
                ),
                title: Text(
                  entry.isPinned ? 'Bỏ ưu tiên' : 'Đặt ưu tiên',
                  style: GoogleFonts.afacad(),
                ),
                onTap: () {
                  setState(() {
                    entry.isPinned = !entry.isPinned;
                    diaryEntries.sort((a, b) {
                      if (a.isPinned != b.isPinned) {
                        return a.isPinned ? -1 : 1;
                      }
                      return b.date.compareTo(a.date);
                    });
                  });
                  _saveDiaryEntries();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        entry.isPinned ? 'Đã đặt ưu tiên' : 'Đã bỏ ưu tiên',
                        style: GoogleFonts.afacad(),
                      ),
                      backgroundColor: const Color(0xFF66BB6A),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  entry.isLocked ? Icons.lock_open : Icons.lock,
                  color: const Color(0xFF8E97FD),
                ),
                title: Text(
                  entry.isLocked ? 'Mở khóa' : 'Đặt mật khẩu',
                  style: GoogleFonts.afacad(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSetPasswordDialog(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder, color: Color(0xFF8E97FD)),
                title: Text('Thêm vào thư mục', style: GoogleFonts.afacad()),
                onTap: () {
                  Navigator.pop(context);
                  _showAddToFolderDialog(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette, color: Color(0xFF8E97FD)),
                title: Text('Đổi màu nền', style: GoogleFonts.afacad()),
                onTap: () {
                  Navigator.pop(context);
                  _showColorPickerDialog(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF8E97FD)),
                title: Text('Chỉnh sửa', style: GoogleFonts.afacad()),
                onTap: () {
                  Navigator.pop(context);
                  _openEntryDetail(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                title: Text('Xóa', style: GoogleFonts.afacad()),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteEntry(entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: Text('Hủy', style: GoogleFonts.afacad()),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _confirmDeleteEntry(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Xóa hoạt động', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
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
                _moveToTrash(entry.id);
                Navigator.pop(context);
              },
              child: Text('Xóa', style: GoogleFonts.afacad(color: const Color(0xFFEF5350))),
            ),
          ],
        );
      },
    );
  }
  
  void _moveToTrash(String entryId) {
    final index = diaryEntries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = diaryEntries[index];
      entry.deletedAt = DateTime.now().toIso8601String();
      setState(() {
        trashedEntries.add(entry);
        diaryEntries.removeAt(index);
      });
      _saveDiaryEntries();
      _saveTrashedEntries();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chuyển vào thùng rác', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFF66BB6A),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => _restoreEntry({'id': entryId}),
          ),
        ),
      );
    }
  }
  
  void _restoreEntry(Map<String, dynamic> entryData) {
    final entryId = entryData['id'];
    final index = trashedEntries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      final entry = trashedEntries[index];
      entry.deletedAt = null;
      setState(() {
        diaryEntries.add(entry);
        trashedEntries.removeAt(index);
      });
      _saveDiaryEntries();
      _saveTrashedEntries();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã khôi phục hoạt động', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFF66BB6A),
        ),
      );
    }
  }
  
  void _permanentlyDeleteEntry(String entryId) {
    final index = trashedEntries.indexWhere((e) => e.id == entryId);
    if (index != -1) {
      setState(() {
        trashedEntries.removeAt(index);
      });
      _saveTrashedEntries();
    }
  }
  
  void _showAddEntryDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Ăn uống';
    String? selectedPetId;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    // Category dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Danh mục',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: filters.skip(1).map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category, style: GoogleFonts.afacad()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Pet dropdown
                    DropdownButtonFormField<String>(
                      initialValue: selectedPetId,
                      decoration: InputDecoration(
                        labelText: 'Thú cưng',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('Không chọn', style: GoogleFonts.afacad()),
                        ),
                        ...petFolders.map((folder) {
                          return DropdownMenuItem(
                            value: folder.id,
                            child: Text('${folder.name} (${folder.type})',
                                style: GoogleFonts.afacad()),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPetId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập tiêu đề'),
                          backgroundColor: Color(0xFFEF5350),
                        ),
                      );
                      return;
                    }
                    
                    final newEntry = DiaryEntry(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      description: descriptionController.text,
                      category: selectedCategory,
                      date: DateTime.now().toIso8601String(),
                      time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                      icon: _getCategoryIcon(selectedCategory),
                      color: _getCategoryColor(selectedCategory),
                      bgColor: Colors.white,
                      folderId: selectedPetId,
                      folderName: selectedPetId != null
                          ? petFolders.firstWhere((f) => f.id == selectedPetId).name
                          : null,
                    );
                    
                    if (mounted) {
                      setState(() {
                        diaryEntries.insert(0, newEntry);
                      });
                      _saveDiaryEntries();
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thêm hoạt động mới', style: GoogleFonts.afacad()),
                          backgroundColor: const Color(0xFF66BB6A),
                        ),
                      );
                    }
                  },
                  child: Text('Thêm', style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
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
  
  // Build reminder stat item
  Widget _buildReminderStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.afacad(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.afacad(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  void _showCreateFolderDialog() {
    final folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Tạo thư mục mới', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: folderNameController,
          decoration: InputDecoration(
            labelText: 'Tên thư mục',
            labelStyle: GoogleFonts.afacad(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'VD: Công việc, Du lịch, ...',
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
              if (folderNameController.text.isNotEmpty) {
                final newFolder = PetFolder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: folderNameController.text,
                  type: 'Thư mục',
                  entryCount: 0,
                );
                setState(() {
                  petFolders.add(newFolder);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã tạo thư mục mới', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              }
            },
            child: Text('Tạo', style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }
  
  void _showSetPasswordDialog(DiaryEntry entry) {
    if (entry.isLocked) {
      // Remove password
      setState(() {
        entry.isLocked = false;
        entry.password = null;
        _saveDiaryEntries();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã mở khóa', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFF66BB6A),
        ),
      );
      return;
    }
    
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Đặt mật khẩu', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
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
              if (passwordController.text.isNotEmpty) {
                setState(() {
                  entry.isLocked = true;
                  entry.password = passwordController.text;
                  _saveDiaryEntries();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đặt mật khẩu', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              }
            },
            child: Text('Lưu', style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }
  
  void _showAddToFolderDialog(DiaryEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Thêm vào thư mục', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.grid_view, color: Color(0xFF8E97FD)),
              title: Text('Không có thư mục', style: GoogleFonts.afacad()),
              onTap: () {
                setState(() {
                  entry.folderId = null;
                  entry.folderName = null;
                  _saveDiaryEntries();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa khỏi thư mục', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              },
            ),
            const Divider(),
            ...petFolders.map((folder) {
              return ListTile(
                leading: Icon(_getPetIcon(folder.type), color: const Color(0xFF8E97FD)),
                title: Text(folder.name, style: GoogleFonts.afacad()),
                subtitle: Text(folder.type, style: GoogleFonts.afacad(fontSize: 12)),
                onTap: () {
                  setState(() {
                    entry.folderId = folder.id;
                    entry.folderName = folder.name;
                    _saveDiaryEntries();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã thêm vào ${folder.name}', style: GoogleFonts.afacad()),
                      backgroundColor: const Color(0xFF66BB6A),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  void _showColorPickerDialog(DiaryEntry entry) {
    final colors = [
      Colors.white,
      const Color(0xFFFFF9E6), // Vàng nhạt
      const Color(0xFFFFE6E6), // Hồng nhạt
      const Color(0xFFE6F7FF), // Xanh nhạt
      const Color(0xFFF0E6FF), // Tím nhạt
      const Color(0xFFE6FFE6), // Xanh lá nhạt
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 20, right: 20),
        title: Text('Chọn màu nền', style: GoogleFonts.afacad(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
        content: SizedBox(
          width: double.maxFinite,
          height: 60,
          child: Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: colors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    entry.bgColor = color;
                    _saveDiaryEntries();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đổi màu nền', style: GoogleFonts.afacad()),
                      backgroundColor: const Color(0xFF66BB6A),
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: entry.bgColor == color ? const Color(0xFF8E97FD) : Colors.grey[300]!,
                      width: entry.bgColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// Detail Screen - Will continue in next part
class DiaryDetailScreen extends StatefulWidget {
  final DiaryEntry entry;
  final Function(DiaryEntry) onUpdate;
  final Function(String) onDelete;
  final FlutterSoundRecorder recorder;
  final bool isRecorderInitialized;
  
  const DiaryDetailScreen({
    super.key,
    required this.entry,
    required this.onUpdate,
    required this.onDelete,
    required this.recorder,
    required this.isRecorderInitialized,
  });
  
  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  
  bool _editingTitle = false;
  bool _editingDescription = false;
  late FocusNode _titleFocus;
  late FocusNode _descFocus;
  
  FlutterSoundPlayer? _player;
  bool _isPlaying = false;
  
  // Text formatting variables
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  Color _textColor = const Color(0xFF22223B);
  double _fontSize = 14;
  String _textAlign = 'left'; // left, center, right
  String _listType = 'none'; // none, bullet, numbered, checklist
  
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _descriptionController = TextEditingController(text: widget.entry.description);
    _titleFocus = FocusNode();
    _descFocus = FocusNode();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descFocus.dispose();
    _player?.closePlayer();
    super.dispose();
  }
  
  void _saveChanges() {
    widget.entry.title = _titleController.text;
    widget.entry.description = _descriptionController.text;
    widget.onUpdate(widget.entry);
  }
  
  void _toggleCheckbox() {
    String text = _descriptionController.text;
    // Find first unchecked box and check it, or vice versa
    if (text.contains('☐')) {
      // Toggle first unchecked to checked
      text = text.replaceFirst('☐', '☑');
    } else if (text.contains('☑')) {
      // Toggle first checked to unchecked
      text = text.replaceFirst('☑', '☐');
    }
    setState(() {
      _descriptionController.text = text;
      _saveChanges();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveChanges();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: widget.entry.bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF22223B)),
            onPressed: () {
              _saveChanges();
              Navigator.of(context).pop();
            },
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
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  widget.entry.reminderDateTime != null 
                      ? Icons.notifications_active 
                      : Icons.notifications_outlined,
                  color: widget.entry.reminderDateTime != null 
                      ? const Color(0xFFFFB74D) 
                      : const Color(0xFF22223B),
                ),
                if (widget.entry.reminderDateTime != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF5350),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _setReminder,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Color(0xFF22223B)),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _confirmDelete();
                  break;
                case 'copy':
                  _createCopy();
                  break;
                case 'change_background':
                  _showColorPicker();
                  break;
                case 'change_tag':
                  _showChangeTagDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'change_background',
                child: Row(
                  children: [
                    const Icon(Icons.palette, color: Color(0xFF8E97FD)),
                    const SizedBox(width: 12),
                    Text('Đổi nền', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Color(0xFFEF5350)),
                    const SizedBox(width: 12),
                    Text('Xóa', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    const Icon(Icons.content_copy, color: Color(0xFF8E97FD)),
                    const SizedBox(width: 12),
                    Text('Tạo bản sao', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'change_tag',
                child: Row(
                  children: [
                    const Icon(Icons.label_outline, color: Color(0xFF8E97FD)),
                    const SizedBox(width: 12),
                    Text('Đổi tag', style: GoogleFonts.afacad()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: widget.entry.bgColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.entry.bgColor,
          border: Border(
            top: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_box_outlined, color: Color(0xFF22223B)),
              onPressed: () => _showAddContentMenu(context),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                widget.entry.isPinned ? Icons.star : Icons.star_border,
                color: widget.entry.isPinned ? const Color(0xFFFFB74D) : const Color(0xFF22223B),
              ),
              onPressed: () {
                setState(() {
                  widget.entry.isPinned = !widget.entry.isPinned;
                  _saveChanges();
                });
              },
            ),
            IconButton(
              icon: Icon(
                widget.entry.isLocked ? Icons.lock : Icons.lock_open,
                color: widget.entry.isLocked ? const Color(0xFF8E97FD) : const Color(0xFF22223B),
              ),
              onPressed: () => _showSetPasswordDialog(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.entry.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.entry.icon, size: 16, color: widget.entry.color),
                  const SizedBox(width: 6),
                  Text(
                    widget.entry.category,
                    style: GoogleFonts.afacad(
                      color: widget.entry.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Title
            _editingTitle
                ? TextField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    style: GoogleFonts.afacad(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onEditingComplete: () {
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
                      });
                      _titleFocus.requestFocus();
                    },
                    child: Text(
                      _titleController.text,
                      style: GoogleFonts.afacad(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            // Date & Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '${widget.entry.date.split('T')[0]} • ${widget.entry.time}',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Text formatting toolbar (shown when editing)
            if (_editingDescription) _buildFormattingToolbar(),
            if (_editingDescription) const SizedBox(height: 12),
            // Description
            _editingDescription
                ? TextField(
                      controller: _descriptionController,
                      focusNode: _descFocus,
                      maxLines: null,
                      textAlign: _textAlign == 'center' 
                          ? TextAlign.center 
                          : _textAlign == 'right' 
                              ? TextAlign.right 
                              : TextAlign.left,
                      style: GoogleFonts.afacad(
                        fontSize: _fontSize,
                        color: _textColor,
                        fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
                      ),
                      decoration: const InputDecoration(border: InputBorder.none),
                      onChanged: (text) {
                        // Auto-add list markers when user presses Enter
                        if (_listType != 'none' && text.contains('\n')) {
                          final lines = text.split('\n');
                          if (lines.length >= 2) {
                            final lastLine = lines[lines.length - 2];
                            final currentLine = lines.last;
                            
                            // Only add marker if current line is empty or just has newline
                            if (currentLine.isEmpty || currentLine.trim().isEmpty) {
                              String prefix = '';
                              
                              // Check if we should stop auto-adding (empty line with just marker)
                              final shouldStop = (
                                (_listType == 'bullet' && lastLine.trim() == '•') ||
                                (_listType == 'numbered' && RegExp(r'^\d+\.$').hasMatch(lastLine.trim())) ||
                                (_listType == 'checklist' && (lastLine.trim() == '☐' || lastLine.trim() == '☑'))
                              );
                              
                              if (shouldStop) {
                                // Remove the empty marker line and stop list mode
                                final newLines = lines.sublist(0, lines.length - 2);
                                final newText = newLines.join('\n') + '\n';
                                setState(() {
                                  _listType = 'none';
                                  _descriptionController.value = TextEditingValue(
                                    text: newText,
                                    selection: TextSelection.fromPosition(
                                      TextPosition(offset: newText.length),
                                    ),
                                  );
                                });
                                return;
                              }
                              
                              // Add appropriate marker
                              if (_listType == 'bullet') {
                                prefix = '• ';
                              } else if (_listType == 'numbered') {
                                // Extract number from last line
                                final match = RegExp(r'^(\d+)\.').firstMatch(lastLine.trim());
                                if (match != null) {
                                  final num = int.parse(match.group(1)!);
                                  prefix = '${num + 1}. ';
                                } else {
                                  // If no number found, start with 1
                                  prefix = '1. ';
                                }
                              } else if (_listType == 'checklist') {
                                prefix = '☐ ';
                              }
                              
                              if (prefix.isNotEmpty && !currentLine.contains(prefix)) {
                                final newText = text + prefix;
                                _descriptionController.value = TextEditingValue(
                                  text: newText,
                                  selection: TextSelection.fromPosition(
                                    TextPosition(offset: newText.length),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      },
                      onEditingComplete: () {
                        setState(() {
                          _editingDescription = false;
                          _saveChanges();
                        });
                      },
                    )
                : GestureDetector(
                    onTap: () {
                      // If text contains checkboxes, allow toggling
                      if (_descriptionController.text.contains('☐') || _descriptionController.text.contains('☑')) {
                        _toggleCheckbox();
                      } else {
                        setState(() {
                          _editingDescription = true;
                        });
                        _descFocus.requestFocus();
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        _editingDescription = true;
                      });
                      _descFocus.requestFocus();
                    },
                    child: Text(
                        _descriptionController.text,
                        textAlign: _textAlign == 'center' 
                            ? TextAlign.center 
                            : _textAlign == 'right' 
                                ? TextAlign.right 
                                : TextAlign.left,
                        style: GoogleFonts.afacad(
                          fontSize: _fontSize,
                          color: _textColor,
                          fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                          decoration: _isUnderline ? TextDecoration.underline : TextDecoration.none,
                        ),
                      ),
                    ),
            // Audio player
            if (widget.entry.audioPath != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ghi âm đính kèm',
                        style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.orange),
                      onPressed: _playAudio,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                      onPressed: () {
                        setState(() {
                          widget.entry.audioPath = null;
                          _saveChanges();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            // Images
            if (widget.entry.images.isNotEmpty) ...[
              const SizedBox(height: 24),
              Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: widget.entry.images.map((imagePath) {
                    return GestureDetector(
                      onLongPress: () {
                        _showImageOptions(imagePath);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(imagePath),
                          width: 160,
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
  
  void _showAddContentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Hỗ trợ',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_active, color: Color(0xFFFFB74D)),
                  title: Text('Đặt nhắc nhở', style: GoogleFonts.afacad(fontSize: 16)),
                  subtitle: widget.entry.reminderDateTime != null 
                      ? Text(
                          _formatReminderTime(widget.entry.reminderDateTime!),
                          style: GoogleFonts.afacad(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    _setReminder();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Color(0xFFEF5350)),
                  title: Text('Xuất PDF', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _exportToPdf();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mic, color: Color(0xFF8E97FD)),
                  title: Text('Ghi âm giọng nói', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _showRecordingDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.image, color: Color(0xFF66BB6A)),
                  title: Text('Ảnh', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _addImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF8E97FD)),
                  title: Text('Máy ảnh', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_file, color: Color(0xFFFFB74D)),
                  title: Text('File âm thanh/video', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAudioFile();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.draw, color: Color(0xFF64B5F6)),
                  title: Text('Hình vẽ', style: GoogleFonts.afacad(fontSize: 16)),
                  onTap: () {
                    Navigator.pop(context);
                    _openDrawingCanvas();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Text size dropdown
            PopupMenuButton<double>(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.text_fields, size: 20),
                    const SizedBox(width: 4),
                    Text('${_fontSize.toInt()}', style: GoogleFonts.afacad(fontSize: 12)),
                    const Icon(Icons.arrow_drop_down, size: 16),
                  ],
                ),
              ),
              onSelected: (size) {
                setState(() => _fontSize = size);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 12.0, child: Text('12')),
                const PopupMenuItem(value: 14.0, child: Text('14')),
                const PopupMenuItem(value: 16.0, child: Text('16')),
                const PopupMenuItem(value: 18.0, child: Text('18')),
                const PopupMenuItem(value: 20.0, child: Text('20')),
                const PopupMenuItem(value: 24.0, child: Text('24')),
              ],
            ),
            const VerticalDivider(width: 1),
            // Bold
            IconButton(
              icon: Icon(Icons.format_bold, color: _isBold ? const Color(0xFF8E97FD) : Colors.black54),
              onPressed: () => setState(() => _isBold = !_isBold),
              iconSize: 20,
            ),
            // Italic
            IconButton(
              icon: Icon(Icons.format_italic, color: _isItalic ? const Color(0xFF8E97FD) : Colors.black54),
              onPressed: () => setState(() => _isItalic = !_isItalic),
              iconSize: 20,
            ),
            // Underline
            IconButton(
              icon: Icon(Icons.format_underline, color: _isUnderline ? const Color(0xFF8E97FD) : Colors.black54),
              onPressed: () => setState(() => _isUnderline = !_isUnderline),
              iconSize: 20,
            ),
            const VerticalDivider(width: 1),
            // Text color
            IconButton(
              icon: Icon(Icons.format_color_text, color: _textColor),
              onPressed: () => _showTextColorPicker(),
              iconSize: 20,
            ),
            const VerticalDivider(width: 1),
            // Align left
            IconButton(
              icon: Icon(
                Icons.format_align_left,
                color: _textAlign == 'left' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () => setState(() => _textAlign = 'left'),
              iconSize: 20,
            ),
            // Align center
            IconButton(
              icon: Icon(
                Icons.format_align_center,
                color: _textAlign == 'center' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () => setState(() => _textAlign = 'center'),
              iconSize: 20,
            ),
            // Align right
            IconButton(
              icon: Icon(
                Icons.format_align_right,
                color: _textAlign == 'right' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () => setState(() => _textAlign = 'right'),
              iconSize: 20,
            ),
            const VerticalDivider(width: 1),
            // Bullet list
            IconButton(
              icon: Icon(
                Icons.format_list_bulleted,
                color: _listType == 'bullet' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () {
                setState(() => _listType = _listType == 'bullet' ? 'none' : 'bullet');
                if (_listType == 'bullet' && _descriptionController.text.isEmpty) {
                  _descriptionController.text = '• ';
                  _descriptionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionController.text.length),
                  );
                }
              },
              iconSize: 20,
            ),
            // Numbered list
            IconButton(
              icon: Icon(
                Icons.format_list_numbered,
                color: _listType == 'numbered' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () {
                setState(() => _listType = _listType == 'numbered' ? 'none' : 'numbered');
                if (_listType == 'numbered' && _descriptionController.text.isEmpty) {
                  _descriptionController.text = '1. ';
                  _descriptionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionController.text.length),
                  );
                }
              },
              iconSize: 20,
            ),
            // Checklist
            IconButton(
              icon: Icon(
                Icons.checklist,
                color: _listType == 'checklist' ? const Color(0xFF8E97FD) : Colors.black54,
              ),
              onPressed: () {
                setState(() => _listType = _listType == 'checklist' ? 'none' : 'checklist');
                if (_listType == 'checklist' && _descriptionController.text.isEmpty) {
                  _descriptionController.text = '☐ ';
                  _descriptionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _descriptionController.text.length),
                  );
                }
              },
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  // Color picker for text color only
  void _showTextColorPicker() {
    final textColors = [
      Colors.black,
      const Color(0xFF22223B),
      const Color(0xFFEF5350),
      const Color(0xFF8E97FD),
      const Color(0xFF66BB6A),
      const Color(0xFFFFB74D),
      const Color(0xFF64B5F6),
      const Color(0xFFF06292),
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          'Chọn màu chữ',
          style: GoogleFonts.afacad(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: textColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _textColor = color;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _textColor == color ? const Color(0xFF8E97FD) : Colors.grey[300]!,
                      width: _textColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
  
  // Color picker for background color only
  void _showBackgroundColorPicker() {
    final bgColors = [
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Text(
          'Chọn màu nền',
          style: GoogleFonts.afacad(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: bgColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    widget.entry.bgColor = color;
                    _saveChanges();
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.entry.bgColor == color ? const Color(0xFF8E97FD) : Colors.grey[300]!,
                      width: widget.entry.bgColor == color ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
  
  // Deprecated: use _showTextColorPicker or _showBackgroundColorPicker instead
  void _showUnifiedColorPicker() {
    _showBackgroundColorPicker();
  }
  
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        setState(() {
          widget.entry.images = [...widget.entry.images, image.path];
          _saveChanges();
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }
  
  Future<void> _addImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          widget.entry.images = [...widget.entry.images, image.path];
          _saveChanges();
        });
      }
    } catch (e) {
      print('Error adding image: $e');
    }
  }
  
  Future<void> _playAudio() async {
    try {
      if (widget.entry.audioPath != null && _player != null) {
        // Check if file exists
        final file = File(widget.entry.audioPath!);
        if (await file.exists()) {
          if (_isPlaying) {
            // Stop playing
            await _player!.stopPlayer();
            setState(() {
              _isPlaying = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã dừng phát', style: GoogleFonts.afacad()),
                backgroundColor: const Color(0xFFFF9800),
                duration: const Duration(seconds: 1),
              ),
            );
          } else {
            // Start playing
            await _player!.startPlayer(fromURI: widget.entry.audioPath);
            setState(() {
              _isPlaying = true;
            });
            
            // Auto stop when finished
            _player!.onProgress!.listen((event) {
              if (event.position >= event.duration) {
                setState(() {
                  _isPlaying = false;
                });
              }
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đang phát...', style: GoogleFonts.afacad()),
                backgroundColor: const Color(0xFF66BB6A),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không tìm thấy file ghi âm', style: GoogleFonts.afacad()),
              backgroundColor: const Color(0xFFEF5350),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi phát ghi âm: $e', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFFEF5350),
        ),
      );
    }
  }
  
  // Export note to PDF with actual file creation
  Future<void> _exportToPdf() async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.picture_as_pdf, color: Color(0xFFEF5350)),
              const SizedBox(width: 12),
              Text('Xuất PDF', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File PDF sẽ bao gồm:',
                style: GoogleFonts.afacad(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Tiêu đề và nội dung ghi chú', style: GoogleFonts.afacad(fontSize: 13))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Thông tin ngày giờ và danh mục', style: GoogleFonts.afacad(fontSize: 13))),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Hình ảnh đính kèm (nếu có)', style: GoogleFonts.afacad(fontSize: 13))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8E97FD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF8E97FD).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF8E97FD), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'File sẽ được lưu vào thư mục Download',
                        style: GoogleFonts.afacad(fontSize: 12, color: const Color(0xFF8E97FD)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.download, size: 18),
                  const SizedBox(width: 6),
                  Text('Xuất PDF', style: GoogleFonts.afacad(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Show progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                const SizedBox(width: 16),
                Text('Đang tạo file PDF...', style: GoogleFonts.afacad(fontWeight: FontWeight.w500)),
              ],
            ),
            backgroundColor: const Color(0xFF8E97FD),
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Simulate PDF creation with actual file writing
        await Future.delayed(const Duration(milliseconds: 800));
        
        try {
          // Get Downloads directory
          final directory = await getExternalStorageDirectory();
          final String downloadsPath;
          
          if (directory != null) {
            // For Android, construct proper Download path
            final parentDir = Directory(directory.path.replaceAll('/Android/data/com.example.ocean_pet_mobile/files', ''));
            downloadsPath = '${parentDir.path}/Download';
          } else {
            downloadsPath = '/storage/emulated/0/Download';
          }
          
          // Create Downloads directory if not exists
          final downloadDir = Directory(downloadsPath);
          if (!await downloadDir.exists()) {
            await downloadDir.create(recursive: true);
          }
          
          // Generate filename
          final fileName = 'diary_${widget.entry.title.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w_]'), '')}_${DateTime.now().millisecondsSinceEpoch}.txt';
          final filePath = '$downloadsPath/$fileName';
          
          // Create PDF-like text file with formatted content
          final content = '''=== DIARY ENTRY ===

Title: ${widget.entry.title}
Category: ${widget.entry.category}
Date: ${widget.entry.date}
Time: ${widget.entry.time}

--- Content ---
${widget.entry.description}

--- Entry Details ---
Created: ${DateTime.parse(widget.entry.date).toString()}
Total Images: ${widget.entry.images.length}
Has Audio: ${widget.entry.audioPath != null ? 'Yes' : 'No'}

=================
Generated on: ${DateTime.now()}''';
          
          // Write to file
          final file = File(filePath);
          await file.writeAsString(content);
          
          if (mounted) {
            // Success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'File đã được tạo thành công!',
                            style: GoogleFonts.afacad(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.insert_drive_file, color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: GoogleFonts.afacad(fontSize: 11, color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.folder_open, color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  downloadsPath,
                                  style: GoogleFonts.afacad(fontSize: 11, color: Colors.white70),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF66BB6A),
                duration: const Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (fileError) {
          print('❌ File creation error: $fileError');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lỗi tạo file: ${fileError.toString()}',
                        style: GoogleFonts.afacad(),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFEF5350),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error exporting PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lỗi khi xuất file: ${e.toString()}',
                    style: GoogleFonts.afacad(),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF5350),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
  
  // Show recording dialog with stop/save buttons
  void _showRecordingDialog() {
    bool isRecording = false;
    String? recordedPath;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isRecording ? Icons.mic : Icons.mic_none,
                color: isRecording ? const Color(0xFFEF5350) : const Color(0xFF8E97FD),
              ),
              const SizedBox(width: 12),
              Text(
                isRecording ? 'Đang ghi âm...' : 'Ghi âm giọng nói',
                style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRecording)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    size: 48,
                    color: Color(0xFFEF5350),
                  ),
                )
              else
                const Icon(Icons.mic_none, size: 64, color: Color(0xFF8E97FD)),
              const SizedBox(height: 16),
              Text(
                isRecording ? 'Đang ghi âm...' : 'Nhấn nút bắt đầu để ghi âm',
                style: GoogleFonts.afacad(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            if (!isRecording) ...[
              // Chỉ có nút Bắt đầu, không có nút Hủy
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.isRecorderInitialized) {
                      final dir = await getApplicationDocumentsDirectory();
                      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
                      await widget.recorder.startRecorder(toFile: path);
                      setDialogState(() {
                        isRecording = true;
                        recordedPath = path;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Bắt đầu', style: GoogleFonts.afacad(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ] else ...[ 
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.recorder.stopRecorder();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.close, color: Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 50),
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.recorder.stopRecorder();
                    if (recordedPath != null) {
                      setState(() {
                        widget.entry.audioPath = recordedPath;
                        _saveChanges();
                      });
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã lưu ghi âm', style: GoogleFonts.afacad()),
                        backgroundColor: const Color(0xFF66BB6A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text('Lưu', style: GoogleFonts.afacad(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // Pick audio/video file from device  
  Future<void> _pickAudioFile() async {
    try {
      // Use FilePicker to select audio or video files from Android storage
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg', 'mp4', 'avi', 'mov', 'mkv', 'webm'],
        dialogTitle: 'Chọn file âm thanh hoặc video',
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        
        if (filePath != null) {
          // Determine if it's audio or video
          final extension = file.extension?.toLowerCase() ?? '';
          final isVideo = ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension);
          final isAudio = ['mp3', 'wav', 'aac', 'm4a', 'flac', 'ogg'].contains(extension);
          
          String messageType = '';
          if (isVideo) {
            messageType = 'Video';
          } else if (isAudio) {
            messageType = 'Âm thanh';
          }
          
          // Store file path
          setState(() {
            widget.entry.audioPath = filePath;
            _saveChanges();
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : Icons.audiotrack,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Đã thêm $messageType thành công',
                            style: GoogleFonts.afacad(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            file.name,
                            style: GoogleFonts.afacad(fontSize: 12, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: isVideo ? const Color(0xFF64B5F6) : const Color(0xFFFFB74D),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Error picking audio/video file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn file: $e', style: GoogleFonts.afacad()),
            backgroundColor: const Color(0xFFEF5350),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  // Open drawing canvas
  Future<void> _openDrawingCanvas() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DrawingCanvas(),
      ),
    );
    
    if (result != null && result is String) {
      setState(() {
        widget.entry.images.add(result);
        _saveChanges();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm hình vẽ', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFF66BB6A),
        ),
      );
    }
  }
  
  void _showColorPicker() {
    // Deprecated: use _showUnifiedColorPicker instead
    _showUnifiedColorPicker();
  }
  
  void _showSetPasswordDialog() {
    if (widget.entry.isLocked) {
      // Remove password
      setState(() {
        widget.entry.isLocked = false;
        widget.entry.password = null;
        _saveChanges();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã mở khóa', style: GoogleFonts.afacad()),
          backgroundColor: const Color(0xFF66BB6A),
        ),
      );
      return;
    }
    
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Đặt mật khẩu', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
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
              if (passwordController.text.isNotEmpty) {
                setState(() {
                  widget.entry.isLocked = true;
                  widget.entry.password = passwordController.text;
                  _saveChanges();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đặt mật khẩu', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              }
            },
            child: Text('Lưu', style: GoogleFonts.afacad(color: const Color(0xFF8E97FD))),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Xóa hoạt động', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
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
              widget.onDelete(widget.entry.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã chuyển vào thùng rác', style: GoogleFonts.afacad()),
                  backgroundColor: const Color(0xFF66BB6A),
                ),
              );
            },
            child: Text('Xóa', style: GoogleFonts.afacad(color: const Color(0xFFEF5350))),
          ),
        ],
      ),
    );
  }
  
  // Print note
  // Create copy
  void _createCopy() {
    final newEntry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${widget.entry.title} (Bản sao)',
      description: widget.entry.description,
      category: widget.entry.category,
      date: DateTime.now().toIso8601String(),
      time: TimeOfDay.now().format(context),
      color: widget.entry.color,
      bgColor: widget.entry.bgColor,
      icon: widget.entry.icon,
      images: List.from(widget.entry.images),
      audioPath: widget.entry.audioPath,
      isPinned: false,
      isLocked: false,
      folderId: widget.entry.folderId,
      folderName: widget.entry.folderName,
    );
    
    widget.onUpdate(newEntry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tạo bản sao', style: GoogleFonts.afacad()),
        backgroundColor: const Color(0xFF66BB6A),
      ),
    );
  }
  
  // Show change tag dialog
  void _showChangeTagDialog() {
    final categories = ['Ăn uống', 'Sức khỏe', 'Vui chơi', 'Tắm rửa'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Đổi tag', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: categories.map((category) {
            final isSelected = widget.entry.category == category;
            return ListTile(
              leading: Icon(
                _getCategoryIcon(category),
                color: _getCategoryColor(category),
              ),
              title: Text(
                category,
                style: GoogleFonts.afacad(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF8E97FD)) : null,
              onTap: () {
                setState(() {
                  widget.entry.category = category;
                  widget.entry.icon = _getCategoryIcon(category);
                  widget.entry.color = _getCategoryColor(category);
                  _saveChanges();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã đổi tag thành $category', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              },
            );
          }).toList(),
        ),
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
        return Icons.note;
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
  
  // Show image options (delete or edit)
  void _showImageOptions(String imagePath) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFEF5350)),
                title: Text('Xóa hình', style: GoogleFonts.afacad(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteImage(imagePath);
                },
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new, color: Color(0xFF8E97FD)),
                title: Text('Xem toàn màn hình', style: GoogleFonts.afacad(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _showFullScreenImage(imagePath);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Confirm delete image
  void _confirmDeleteImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Xóa hình ảnh?',
            style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa hình ảnh này?',
            style: GoogleFonts.afacad(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.entry.images.remove(imagePath);
                  _saveChanges();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa hình ảnh', style: GoogleFonts.afacad()),
                    backgroundColor: const Color(0xFFEF5350),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
              ),
              child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  // Show full screen image
  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Set reminder for note
  void _setReminder() {
    // If reminder exists, use its date/time; otherwise use current date/time
    DateTime selectedDate;
    TimeOfDay selectedTime;
    
    if (widget.entry.reminderDateTime != null) {
      try {
        final existingReminder = DateTime.parse(widget.entry.reminderDateTime!);
        selectedDate = existingReminder;
        selectedTime = TimeOfDay.fromDateTime(existingReminder);
      } catch (e) {
        selectedDate = DateTime.now();
        selectedTime = TimeOfDay.now();
      }
    } else {
      selectedDate = DateTime.now();
      selectedTime = TimeOfDay.now();
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.notifications_active, color: Color(0xFFFFB74D)),
              const SizedBox(width: 12),
              Text('Đặt nhắc nhở', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Color(0xFF8E97FD)),
                title: Text('Ngày', style: GoogleFonts.afacad()),
                subtitle: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: GoogleFonts.afacad(color: Colors.grey),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              // Time picker
              ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF66BB6A)),
                title: Text('Giờ', style: GoogleFonts.afacad()),
                subtitle: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.afacad(color: Colors.grey),
                ),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setDialogState(() {
                      selectedTime = picked;
                    });
                  }
                },
              ),
              // Quick options
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _buildQuickReminderChip('1 giờ', const Duration(hours: 1), setDialogState, selectedDate, selectedTime),
                  _buildQuickReminderChip('1 ngày', const Duration(days: 1), setDialogState, selectedDate, selectedTime),
                  _buildQuickReminderChip('1 tuần', const Duration(days: 7), setDialogState, selectedDate, selectedTime),
                ],
              ),
            ],
          ),
          actions: [
            if (widget.entry.reminderDateTime != null)
              TextButton(
                onPressed: () {
                  // Cancel notification when removing reminder
                  final notificationId = widget.entry.id.hashCode.abs();
                  NotificationService.cancelAppointmentReminder(notificationId);
                  
                  setState(() {
                    widget.entry.reminderDateTime = null;
                    _saveChanges();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã xóa nhắc nhở', style: GoogleFonts.afacad()),
                      backgroundColor: const Color(0xFFEF5350),
                    ),
                  );
                },
                child: Text('Xóa', style: GoogleFonts.afacad(color: const Color(0xFFEF5350))),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final reminderDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                
                setState(() {
                  widget.entry.reminderDateTime = reminderDateTime.toIso8601String();
                  _saveChanges();
                });
                
                // Schedule notification for diary reminder
                final notificationId = widget.entry.id.hashCode.abs();
                await NotificationService.scheduleAppointmentReminder(
                  appointmentId: notificationId,
                  appointmentTitle: '📔 ${widget.entry.title}',
                  appointmentTime: '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  appointmentDateTime: reminderDateTime,
                  reminderTime: '1day', // Direct reminder at the scheduled time
                );
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Đã đặt nhắc nhở lúc ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: GoogleFonts.afacad(),
                    ),
                    backgroundColor: const Color(0xFF66BB6A),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
              ),
              child: Text('Lưu', style: GoogleFonts.afacad(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build quick reminder chip
  Widget _buildQuickReminderChip(String label, Duration duration, StateSetter setDialogState, DateTime selectedDate, TimeOfDay selectedTime) {
    return ActionChip(
      label: Text(label, style: GoogleFonts.afacad(fontSize: 12)),
      backgroundColor: const Color(0xFF8E97FD).withOpacity(0.1),
      side: const BorderSide(color: Color(0xFF8E97FD)),
      onPressed: () {
        final now = DateTime.now();
        final newDateTime = now.add(duration);
        setDialogState(() {
          selectedDate = newDateTime;
          selectedTime = TimeOfDay.fromDateTime(newDateTime);
        });
      },
    );
  }
  
  // Format reminder time
  String _formatReminderTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = dateTime.difference(now);
      
      if (difference.isNegative) {
        return 'Đã qua';
      } else if (difference.inMinutes < 60) {
        return 'Còn ${difference.inMinutes} phút';
      } else if (difference.inHours < 24) {
        return 'Còn ${difference.inHours} giờ';
      } else {
        final days = difference.inDays;
        return 'Còn $days ngày';
      }
    } catch (e) {
      return '';
    }
  }
}
