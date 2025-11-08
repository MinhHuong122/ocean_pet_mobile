import 'package:flutter/material.dart';
import 'package:ocean_pet/services/FirebaseSeedData.dart';

/// Debug Screen để seed dữ liệu mẫu vào Firestore
/// Chỉ dùng cho development/testing
class DebugSeedDataScreen extends StatefulWidget {
  const DebugSeedDataScreen({Key? key}) : super(key: key);

  @override
  State<DebugSeedDataScreen> createState() => _DebugSeedDataScreenState();
}

class _DebugSeedDataScreenState extends State<DebugSeedDataScreen> {
  bool _isLoading = false;
  String _message = '';

  Future<void> _seedAllData() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseSeedData.seedAll();
      setState(() {
        _message = '✅ Seed tất cả dữ liệu thành công!';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _seedCollection(String collection) async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseSeedData.seedCollection(collection);
      setState(() {
        _message = '✅ Seed $collection thành công!';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearAllData() async {
    // Confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa TẤT CẢ dữ liệu? Hành động này không thể hoàn tác!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await FirebaseSeedData.clearAllData();
      setState(() {
        _message = '✅ Xóa tất cả dữ liệu thành công!';
      });
    } catch (e) {
      setState(() {
        _message = '❌ Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌱 Seed Dữ liệu Firebase'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chức năng này chỉ dùng cho development/testing',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seed all button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _seedAllData,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Seed TẤT CẢ dữ liệu mẫu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Individual collections
            const Text(
              'Seed từng collection:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _buildCollectionButton(
              'Folders (Thư mục)',
              'folders',
              Icons.folder,
              Colors.blue,
            ),
            const SizedBox(height: 8),

            _buildCollectionButton(
              'Pets (Thú cưng)',
              'pets',
              Icons.pets,
              Colors.purple,
            ),
            const SizedBox(height: 8),

            _buildCollectionButton(
              'Diary Entries (Nhật ký)',
              'diary_entries',
              Icons.book,
              Colors.teal,
            ),
            const SizedBox(height: 8),

            _buildCollectionButton(
              'Appointments (Lịch hẹn)',
              'appointments',
              Icons.event,
              Colors.orange,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Clear all button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _clearAllData,
              icon: const Icon(Icons.delete_forever),
              label: const Text('🗑️ XÓA TẤT CẢ dữ liệu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Message display
            if (_message.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _message.startsWith('✅')
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('✅')
                        ? Colors.green.shade900
                        : Colors.red.shade900,
                  ),
                ),
              ),

            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionButton(
    String label,
    String collection,
    IconData icon,
    Color color,
  ) {
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : () => _seedCollection(collection),
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.all(12),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}
