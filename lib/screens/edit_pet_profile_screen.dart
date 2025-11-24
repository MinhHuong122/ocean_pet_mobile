import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ocean_pet/services/FirebaseService.dart';
import 'package:ocean_pet/services/CloudinaryService.dart';
import 'package:ocean_pet/helpers/keyboard_utils.dart';

class EditPetProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? existingPet;

  const EditPetProfileScreen({
    super.key,
    this.existingPet,
  });

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> with KeyboardFormMixin {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  TextEditingController _heightController = TextEditingController();
  late TextEditingController _ageController;
  late TextEditingController _notesController;

  // Form data
  String _gender = 'unknown';
  DateTime? _birthDate;
  File? _imageFile;
  String? _existingAvatarUrl;
  String _petType = 'Chó';

  // Pet type options
  final List<String> _petTypes = [
    'Chó',
    'Mèo',
    'Cá',
    'Chim',
    'Hamster',
    'Thỏ',
    'Rùa',
    'Rắn',
    'Heo',
    'Vẹt',
  ];

  // Get only numeric age in years (for edit screen display)
  String _getNumericAge(int? ageMonths) {
    if (ageMonths == null) return '';
    return (ageMonths ~/ 12).toString();
  }

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers với dữ liệu hiện tại nếu đang edit
    if (widget.existingPet != null) {
      final pet = widget.existingPet!;
      _nameController = TextEditingController(text: pet['name'] ?? '');
      _breedController = TextEditingController(text: pet['breed'] ?? '');
      _weightController = TextEditingController(
        text: pet['weight'] != null ? pet['weight'].toString() : '',
      );
      _heightController = TextEditingController(
        text: pet['height'] != null ? pet['height'].toString() : '',
      );
      _ageController = TextEditingController(
        text: pet['age'] != null ? _getNumericAge(pet['age']) : '',
      );
      _notesController = TextEditingController(text: pet['notes'] ?? '');
      _gender = pet['gender'] ?? 'unknown';
      _petType = pet['type'] ?? 'Chó';
      _existingAvatarUrl = pet['avatar_url'];
      
      // Set birthDate từ Firestore
      if (pet['birth_date'] != null) {
        _birthDate = (pet['birth_date'] as dynamic).toDate();
      }
    } else {
      _nameController = TextEditingController();
      _breedController = TextEditingController();
      _weightController = TextEditingController();
      _heightController = TextEditingController();
      _ageController = TextEditingController();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8E97FD),
            ),
          ),
          child: child!,
        );
      },
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        
        // Tự động tính tuổi
        final now = DateTime.now();
        int ageMonths = (now.year - picked.year) * 12 + (now.month - picked.month);
        if (now.day < picked.day && ageMonths > 0) {
          ageMonths--;
        }
        
        if (ageMonths >= 0) {
          _ageController.text = _getNumericAge(ageMonths);
        } else {
          _ageController.text = '0';
        }
      });
    }
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Upload ảnh lên Cloudinary nếu có ảnh mới
      String? avatarUrl = _existingAvatarUrl;
      if (_imageFile != null) {
        try {
          avatarUrl = await CloudinaryService.uploadImage(
            _imageFile!,
            'pets',
            fileName: '${_petType}_${DateTime.now().millisecondsSinceEpoch}',
          );
          print('Đã upload ảnh thú cưng: $avatarUrl');
        } catch (e) {
          print('Upload ảnh thất bại: $e');
        }
      }

      if (widget.existingPet != null) {
        // Update existing pet
        // Calculate age from birth date
        int ageMonths = 0;
        if (_birthDate != null) {
          final now = DateTime.now();
          ageMonths = (now.year - _birthDate!.year) * 12 + (now.month - _birthDate!.month);
          if (now.day < _birthDate!.day && ageMonths > 0) {
            ageMonths--;
          }
        }

        await FirebaseService.updatePet(
          widget.existingPet!['id'],
          {
            'name': _nameController.text.trim(),
            'type': _petType,
            'breed': _breedController.text.trim().isNotEmpty
                ? _breedController.text.trim()
                : null,
            'gender': _gender,
            'birth_date': _birthDate,
            'age': ageMonths,
            'weight': _weightController.text.trim().isNotEmpty
                ? double.tryParse(_weightController.text.trim())
                : null,
            'height': _heightController.text.trim().isNotEmpty
                ? double.tryParse(_heightController.text.trim())
                : null,
            'avatar_url': avatarUrl,
            'notes': _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          },
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã cập nhật ${_nameController.text}'),
              backgroundColor: const Color(0xFF66BB6A),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        // Add new pet
        if (_birthDate == null) {
          throw Exception('Vui lòng chọn ngày sinh');
        }
        
        await FirebaseService.addPet(
          name: _nameController.text.trim(),
          type: _petType,
          gender: _gender,
          birthDate: _birthDate!,
          breed: _breedController.text.trim().isNotEmpty
              ? _breedController.text.trim()
              : null,
          weight: _weightController.text.trim().isNotEmpty
              ? double.tryParse(_weightController.text.trim())
              : null,
          height: _heightController.text.trim().isNotEmpty
              ? double.tryParse(_heightController.text.trim())
              : null,
          avatarUrl: avatarUrl,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm ${_nameController.text}'),
              backgroundColor: const Color(0xFF66BB6A),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingPet != null;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E97FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh sửa thú cưng' : 'Thêm thú cưng mới',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E97FD).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF8E97FD),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _imageFile != null
                                  ? Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                    )
                                  : _existingAvatarUrl != null &&
                                          _existingAvatarUrl!.isNotEmpty
                                      ? Image.network(
                                          _existingAvatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.pets,
                                              size: 60,
                                              color: Color(0xFF8E97FD),
                                            );
                                          },
                                        )
                                      : const Icon(
                                          Icons.pets,
                                          size: 60,
                                          color: Color(0xFF8E97FD),
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8E97FD),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nhấn để thêm/đổi ảnh',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên thú cưng *',
                  labelStyle: GoogleFonts.afacad(),
                  hintText: 'Ví dụ: Meo, Lucky, Milu...',
                  hintStyle: GoogleFonts.afacad(),
                  prefixIcon: const Icon(Icons.pets, color: Color(0xFF8E97FD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF8E97FD), width: 2),
                  ),
                ),
                style: GoogleFonts.afacad(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên thú cưng';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Pet type dropdown
              DropdownButtonFormField<String>(
                initialValue: _petType,
                decoration: InputDecoration(
                  labelText: 'Loại thú cưng *',
                  labelStyle: GoogleFonts.afacad(),
                  prefixIcon:
                      const Icon(Icons.category, color: Color(0xFF8E97FD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF8E97FD), width: 2),
                  ),
                ),
                items: _petTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: GoogleFonts.afacad()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _petType = value!;
                  });
                },
                style: GoogleFonts.afacad(color: Colors.black),
              ),

              const SizedBox(height: 16),

              // Breed field
              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: 'Giống',
                  labelStyle: GoogleFonts.afacad(),
                  hintText: 'Ví dụ: Husky, Corgi, Ba Tư...',
                  hintStyle: GoogleFonts.afacad(),
                  prefixIcon:
                      const Icon(Icons.pets_outlined, color: Color(0xFF8E97FD)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF8E97FD), width: 2),
                  ),
                ),
                style: GoogleFonts.afacad(),
              ),

              const SizedBox(height: 16),

              // Gender selection
              Text(
                'Giới tính',
                style: GoogleFonts.afacad(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderOption('male', 'Đực', Icons.male),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption('female', 'Cái', Icons.female),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderOption('unknown', 'Khác', Icons.help_outline),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Birth date picker
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Ngày sinh',
                    labelStyle: GoogleFonts.afacad(),
                    prefixIcon: const Icon(Icons.cake, color: Color(0xFF8E97FD)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Color(0xFF8E97FD), width: 2),
                    ),
                  ),
                  child: Text(
                    _birthDate != null
                        ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                        : 'Chọn ngày sinh',
                    style: GoogleFonts.afacad(
                      color: _birthDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Age field (auto-calculated)
              TextFormField(
                controller: _ageController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Độ tuổi',
                  labelStyle: GoogleFonts.afacad(),
                  hintText: 'Tự động tính từ ngày sinh',
                  hintStyle: GoogleFonts.afacad(),
                  prefixIcon:
                      const Icon(Icons.calendar_today, color: Color(0xFF8E97FD)),
                  suffixText: 'tuổi',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                style: GoogleFonts.afacad(),
              ),

              const SizedBox(height: 16),

              // Weight and Height fields (side by side)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Cân nặng (kg) *',
                        labelStyle: GoogleFonts.afacad(),
                        hintText: 'Ví dụ: 5.5',
                        hintStyle: GoogleFonts.afacad(),
                        prefixIcon: const Icon(Icons.monitor_weight, color: Color(0xFF8E97FD)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF8E97FD), width: 2),
                        ),
                      ),
                      style: GoogleFonts.afacad(),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final weight = double.tryParse(value.trim());
                          if (weight == null || weight <= 0) {
                            return 'Cân nặng không hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Chiều cao (cm) *',
                        labelStyle: GoogleFonts.afacad(),
                        hintText: 'Ví dụ: 30.5',
                        hintStyle: GoogleFonts.afacad(),
                        prefixIcon: const Icon(Icons.height, color: Color(0xFF8E97FD)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF8E97FD), width: 2),
                        ),
                      ),
                      style: GoogleFonts.afacad(),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final height = double.tryParse(value.trim());
                          if (height == null || height <= 0) {
                            return 'Chiều cao không hợp lệ';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  labelStyle: GoogleFonts.afacad(),
                  hintText: 'Thông tin thêm về thú cưng...',
                  hintStyle: GoogleFonts.afacad(),
                  prefixIcon: const Icon(Icons.note, color: Color(0xFF8E97FD)),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF8E97FD), width: 2),
                  ),
                ),
                style: GoogleFonts.afacad(),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isEdit ? 'Cập nhật' : 'Thêm thú cưng',
                          style: GoogleFonts.afacad(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8E97FD) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.afacad(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
