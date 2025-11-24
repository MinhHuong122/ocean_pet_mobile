// lib/widget/medical_file_picker.dart - Advanced Medical File Picker with Categories
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:url_launcher/url_launcher.dart';

/// Medical file categories for organized record-keeping
enum MedicalFileCategory {
  vaccination('Tiêm chủng', 'ocean-pet/vaccinations'),
  consultation('Khám bệnh', 'ocean-pet/consultations'),
  testResult('Xét nghiệm', 'ocean-pet/test-results'),
  surgery('Phẫu thuật', 'ocean-pet/surgeries'),
  petPhoto('Ảnh thú cưng', 'ocean-pet/pet-photos'),
  legalDoc('Giấy tờ pháp lý', 'ocean-pet/legal-documents'),
  insurance('Bảo hiểm', 'ocean-pet/insurance'),
  other('Khác', 'ocean-pet/other');

  final String label;
  final String cloudinaryFolder;

  const MedicalFileCategory(this.label, this.cloudinaryFolder);
}

class MedicalFilePicker extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onFilesSelected;
  final VoidCallback? onUploadComplete;
  final MedicalFileCategory? initialCategory;

  const MedicalFilePicker({
    super.key,
    required this.onFilesSelected,
    this.onUploadComplete,
    this.initialCategory,
  });

  @override
  State<MedicalFilePicker> createState() => _MedicalFilePickerState();
}

class _MedicalFilePickerState extends State<MedicalFilePicker> {
  Map<MedicalFileCategory, List<Map<String, dynamic>>> filesByCategory = {
    for (var category in MedicalFileCategory.values) category: [],
  };

  MedicalFileCategory? selectedCategory;
  bool isUploading = false;
  double uploadProgress = 0;
  String? uploadingFileName;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory ?? MedicalFileCategory.consultation;
  }

  /// Pick files from device (Android/iOS) for selected category
  Future<void> _pickFiles() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn loại tệp',
              style: GoogleFonts.afacad()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'xlsx', 'xls'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              filesByCategory[selectedCategory]!.add({
                'path': file.path!,
                'name': file.name,
                'size': _formatFileSize(file.size),
                'type': _getFileType(file.extension ?? ''),
                'icon': _getFileIcon(file.extension ?? ''),
                'category': selectedCategory!.label,
                'progress': 0.0,
              });
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${result.files.length} tệp đã chọn cho "${selectedCategory!.label}"',
              style: GoogleFonts.afacad(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi chọn tệp: $e',
            style: GoogleFonts.afacad(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Get total count of all selected files across categories
  int _getTotalFileCount() {
    return filesByCategory.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Get all files from all categories as flat list
  List<Map<String, dynamic>> _getAllFilesFlat() {
    List<Map<String, dynamic>> allFiles = [];
    filesByCategory.forEach((_, files) => allFiles.addAll(files));
    return allFiles;
  }

  /// Upload files to Cloudinary with category-based organization
  Future<void> _uploadFiles() async {
    if (_getTotalFileCount() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn tệp trước khi tải lên',
              style: GoogleFonts.afacad()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
      uploadProgress = 0;
    });

    try {
      // Initialize Cloudinary - Replace with your credentials
      final cloudinary = CloudinaryPublic('dssazeaz6', 'ocean_pet', cache: false);
      
      List<Map<String, dynamic>> allFiles = _getAllFilesFlat();
      
      // For each file, upload to Cloudinary
      for (int i = 0; i < allFiles.length; i++) {
        String filePath = allFiles[i]['path'];
        String fileName = allFiles[i]['name'];
        String category = allFiles[i]['category'];
        
        setState(() {
          uploadingFileName = fileName;
        });
        
        try {
          // Determine Cloudinary folder based on category
          String cloudinaryFolder = 'ocean-pet/medical-records';
          for (var cat in MedicalFileCategory.values) {
            if (cat.label == category) {
              cloudinaryFolder = cat.cloudinaryFolder;
              break;
            }
          }

          // Upload to Cloudinary
          CloudinaryResponse response = await cloudinary.uploadFile(
            CloudinaryFile.fromFile(
              filePath,
              folder: cloudinaryFolder,
            ),
            onProgress: (count, total) {
              setState(() {
                allFiles[i]['progress'] = count / total;
                uploadProgress = (i + (count / total)) / allFiles.length;
              });
            },
          );

          // Check if upload was successful
          if (response.secureUrl.isNotEmpty) {
            allFiles[i]['uploaded'] = true;
            allFiles[i]['url'] = response.secureUrl;
            allFiles[i]['uploadedAt'] = DateTime.now();
            allFiles[i]['cloudinaryFolder'] = cloudinaryFolder;
            print('✅ Uploaded: $fileName -> ${response.secureUrl}');
          } else {
            throw Exception('Upload failed');
          }
        } catch (e) {
          print('❌ Upload error for $fileName: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi tải lên $fileName: $e',
                style: GoogleFonts.afacad(),
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Call onFilesSelected with all uploaded files
      final uploadedFiles = allFiles.where((f) => f['uploaded'] == true).toList();
      if (uploadedFiles.isNotEmpty) {
        widget.onFilesSelected(uploadedFiles);
      }

      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tải lên hoàn tất! (${uploadedFiles.length}/${allFiles.length} tệp)',
              style: GoogleFonts.afacad(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Call callback and close modal
        widget.onUploadComplete?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi tải lên: $e',
              style: GoogleFonts.afacad(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
          uploadProgress = 0;
          uploadingFileName = null;
        });
      }
    }
  }

  /// Remove file from selected category
  void _removeFile(MedicalFileCategory category, int index) {
    setState(() {
      filesByCategory[category]!.removeAt(index);
    });
  }

  /// Clear all files
  void _clearAllFiles() {
    setState(() {
      filesByCategory.forEach((_, list) => list.clear());
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getFileType(String extension) {
    const typeMap = {
      'pdf': 'PDF Document',
      'doc': 'Word Document',
      'docx': 'Word Document',
      'jpg': 'Image (JPG)',
      'jpeg': 'Image (JPEG)',
      'png': 'Image (PNG)',
      'xlsx': 'Excel Sheet',
      'xls': 'Excel Sheet',
    };
    return typeMap[extension.toLowerCase()] ?? 'Unknown';
  }

  IconData _getFileIcon(String extension) {
    final ext = extension.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (['doc', 'docx'].contains(ext)) return Icons.description;
    if (['jpg', 'jpeg', 'png'].contains(ext)) return Icons.image;
    if (['xlsx', 'xls'].contains(ext)) return Icons.table_chart;
    return Icons.attachment;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.5)),
            ),
            child: Center(
              child: Text(
                'Tải tệp y tế theo loại',
                style: GoogleFonts.afacad(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selector
                    Text(
                      'Chọn loại tệp',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: MedicalFileCategory.values.map((category) {
                          bool isSelected = selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                category.label,
                                style: GoogleFonts.afacad(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCategory = selected ? category : null;
                                });
                              },
                              backgroundColor: Colors.grey[100],
                              selectedColor: const Color(0xFF8B5CF6),
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[800],
                              ),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[600], size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hỗ trợ: PDF, Word, Excel, JPG, PNG',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pick Files Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isUploading ? null : _pickFiles,
                        icon: const Icon(Icons.folder_open),
                        label: Text(
                          'Chọn tệp từ điện thoại',
                          style: GoogleFonts.afacad(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Files by Category
                    if (_getTotalFileCount() > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tệp đã chọn (${_getTotalFileCount()})',
                            style: GoogleFonts.afacad(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearAllFiles,
                            child: Text(
                              'Xóa tất cả',
                              style: GoogleFonts.afacad(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...filesByCategory.entries.map((entry) {
                        MedicalFileCategory category = entry.key;
                        List<Map<String, dynamic>> files = entry.value;

                        if (files.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${category.label} (${files.length})',
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Files
                            ...files.asMap().entries.map((entry) {
                              int index = entry.key;
                              var file = entry.value;
                              return _buildFileItem(file, index, category);
                            }),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                    ],

                    // Upload Progress
                    if (isUploading) ...[
                      const SizedBox(height: 16),
                      if (uploadingFileName != null) ...[
                        Text(
                          'Đang tải: $uploadingFileName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.afacad(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: uploadProgress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green[500]!,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(uploadProgress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.afacad(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUploading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.afacad(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8B5CF6),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_getTotalFileCount() == 0 || isUploading)
                        ? null
                        : _uploadFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isUploading ? 'Đang tải...' : 'Tải lên',
                      style: GoogleFonts.afacad(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(Map<String, dynamic> file, int index, MedicalFileCategory category) {
    final progress = file['progress'] as double? ?? 0.0;
    final isUploaded = file['uploaded'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? Colors.green[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  file['icon'] as IconData,
                  color: const Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.afacad(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${file['type']} • ${file['size']}',
                      style: GoogleFonts.afacad(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploading && progress > 0 && progress < 1)
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.afacad(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                )
              else if (isUploaded)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[500],
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _downloadFile(file['url']),
                      child: const Icon(Icons.download_rounded, color: Colors.blueAccent, size: 22),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: () => _removeFile(category, index),
                  child: Icon(
                    Icons.close,
                    color: Colors.red[400],
                    size: 24,
                  ),
                ),
            ],
          ),
          if (isUploading && progress > 0 && progress < 1) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green[500]!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadFile(dynamic url) async {
    if (url == null) return;
    final uri = Uri.tryParse(url.toString());
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được tệp', style: GoogleFonts.afacad())),
      );
    }
  }
}
