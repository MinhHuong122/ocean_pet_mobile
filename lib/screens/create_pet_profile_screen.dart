import 'package:flutter/material.dart';
import 'package:ocean_pet/res/R.dart';
import 'package:ocean_pet/services/FirebaseService.dart';
import 'package:ocean_pet/services/CloudinaryService.dart';
import 'package:ocean_pet/screens/home_screen.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePetProfileScreen extends StatefulWidget {
  final List<String> selectedPetTypes;

  const CreatePetProfileScreen({
    super.key,
    required this.selectedPetTypes,
  });

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isSaving = false;

  // Danh sách form key cho mỗi pet
  late List<GlobalKey<FormState>> _formKeys;
  
  // Danh sách controllers cho mỗi pet
  late List<PetFormData> _petForms;

  @override
  void initState() {
    super.initState();
    _formKeys = List.generate(
      widget.selectedPetTypes.length,
      (index) => GlobalKey<FormState>(),
    );
    _petForms = widget.selectedPetTypes.map((type) {
      return PetFormData(petType: type);
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var form in _petForms) {
      form.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(PetFormData form) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        form.imageFile = File(image.path);
      });
    }
  }

  Future<void> _saveAllPets() async {
    setState(() {
      _isSaving = true;
    });

    try {
      for (int i = 0; i < _petForms.length; i++) {
        final form = _petForms[i];
        
        // Kiểm tra các trường bắt buộc
        if (form.birthDate == null) {
          throw Exception('Vui lòng chọn ngày sinh cho tất cả thú cưng');
        }
        if (form.gender == 'unknown') {
          throw Exception('Vui lòng chọn giới tính cho tất cả thú cưng');
        }

        // Upload ảnh lên Cloudinary nếu có
        String? avatarUrl;
        if (form.imageFile != null) {
          try {
            avatarUrl = await CloudinaryService.uploadImage(
              form.imageFile!,
              'pets', // folder name
              fileName: '${form.petType}_${DateTime.now().millisecondsSinceEpoch}',
            );
            print('✅ Đã upload ảnh thú cưng: $avatarUrl');
          } catch (e) {
            print('⚠️ Upload ảnh thất bại: $e');
            // Tiếp tục lưu pet mà không có ảnh
          }
        }

        await FirebaseService.addPet(
          name: form.nameController.text.trim(),
          type: form.petType,
          gender: form.gender,
          birthDate: form.birthDate!,
          breed: form.breedController.text.trim().isNotEmpty
              ? form.breedController.text.trim()
              : null,
          weight: form.weightController.text.trim().isNotEmpty
              ? double.tryParse(form.weightController.text.trim())
              : null,
          height: form.heightController.text.trim().isNotEmpty
              ? double.tryParse(form.heightController.text.trim())
              : null,
          avatarUrl: avatarUrl,
          notes: form.notesController.text.trim().isNotEmpty
              ? form.notesController.text.trim()
              : null,
        );
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
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

  void _nextPage() {
    if (_currentIndex < widget.selectedPetTypes.length - 1) {
      if (_formKeys[_currentIndex].currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_formKeys[_currentIndex].currentState!.validate()) {
        _saveAllPets();
      }
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          'Tạo hồ sơ thú cưng',
          style: TextStyle(
            color: Colors.black,
            fontFamily: R.font.sfpro,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: List.generate(
                widget.selectedPetTypes.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      left: index > 0 ? 4 : 0,
                      right: index < widget.selectedPetTypes.length - 1 ? 4 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page indicator text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Thú cưng ${_currentIndex + 1}/${widget.selectedPetTypes.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: R.font.sfpro,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Form pages
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.selectedPetTypes.length,
              itemBuilder: (context, index) {
                return _buildPetForm(index);
              },
            ),
          ),

          // Bottom button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentIndex < widget.selectedPetTypes.length - 1
                            ? 'Tiếp theo'
                            : 'Hoàn tất',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: R.font.sfpro,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetForm(int index) {
    final form = _petForms[index];
    final petType = widget.selectedPetTypes[index];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeys[index],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet type icon/photo and name
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(form),
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: form.imageFile != null
                                ? Image.file(
                                    form.imageFile!,
                                    fit: BoxFit.cover,
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Image.asset(
                                      _getPetIcon(petType),
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.pets,
                                          size: 60,
                                          color: Color(0xFF8B5CF6),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
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
                    'Nhấn để thêm ảnh',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thông tin $petType',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: R.font.sfpro,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: form.nameController,
              decoration: InputDecoration(
                labelText: 'Tên thú cưng *',
                hintText: 'Ví dụ: Meo, Milu, Lucky...',
                prefixIcon: const Icon(Icons.pets),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên thú cưng';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Breed field
            TextFormField(
              controller: form.breedController,
              decoration: InputDecoration(
                labelText: 'Giống',
                hintText: 'Ví dụ: Husky, Corgi, Ba Tư...',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Gender selection
            Text(
              'Giới tính',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: R.font.sfpro,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildGenderOption(form, 'male', 'Đực', Icons.male),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption(form, 'female', 'Cái', Icons.female),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGenderOption(form, 'unknown', 'Khác', Icons.help_outline),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Weight and Height fields (side by side)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: form.weightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Cân nặng (kg) *',
                      hintText: 'Ví dụ: 5.5',
                      prefixIcon: const Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                    ),
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
                    controller: form.heightController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Chiều cao (cm) *',
                      hintText: 'Ví dụ: 30.5',
                      prefixIcon: const Icon(Icons.height),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                      ),
                    ),
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

            // Birth date picker (required)
            InkWell(
              onTap: () => _selectBirthDate(context, form),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày sinh *',
                  prefixIcon: const Icon(Icons.cake),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                  ),
                  errorBorder: form.birthDate == null
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red, width: 1),
                        )
                      : null,
                ),
                child: Text(
                  form.birthDate != null
                      ? DateFormat('dd/MM/yyyy').format(form.birthDate!)
                      : 'Chọn ngày sinh',
                  style: TextStyle(
                    color: form.birthDate != null ? Colors.black : Colors.red,
                    fontFamily: R.font.sfpro,
                    fontWeight: form.birthDate == null ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Age field (auto-calculated from birth date)
            TextFormField(
              controller: form.ageController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Độ tuổi',
                hintText: 'Tự động tính từ ngày sinh',
                prefixIcon: const Icon(Icons.calendar_today),
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
            ),

            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: form.notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Thông tin thêm về thú cưng...',
                prefixIcon: const Icon(Icons.note),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(PetFormData form, String value, String label, IconData icon) {
    final isSelected = form.gender == value;
    return InkWell(
      onTap: () {
        setState(() {
          form.gender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[200],
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
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: R.font.sfpro,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context, PetFormData form) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: form.birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6),
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
        form.birthDate = picked;
        
        // Tự động tính tuổi
        final now = DateTime.now();
        int age = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        
        // Cập nhật text field tuổi
        if (age >= 0) {
          form.ageController.text = age.toString();
        } else {
          form.ageController.text = '0';
        }
      });
    }
  }

  String _getPetIcon(String petType) {
    final Map<String, String> icons = {
      'Mèo': 'lib/res/drawables/setting/001-cat.png',
      'Cá': 'lib/res/drawables/setting/002-fish.png',
      'Rắn': 'lib/res/drawables/setting/003-snake.png',
      'Rùa': 'lib/res/drawables/setting/004-turtle.png',
      'Heo': 'lib/res/drawables/setting/005-pig.png',
      'Thỏ': 'lib/res/drawables/setting/006-rabbit.png',
      'Chó': 'lib/res/drawables/setting/007-dog.png',
      'Vẹt': 'lib/res/drawables/setting/008-parrot.png',
      'Hamster': 'lib/res/drawables/setting/009-squirrel.png',
    };
    return icons[petType] ?? 'lib/res/drawables/setting/001-cat.png';
  }
}

class PetFormData {
  final String petType;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String gender = 'unknown';
  DateTime? birthDate;
  File? imageFile;

  PetFormData({required this.petType});

  void dispose() {
    nameController.dispose();
    breedController.dispose();
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    notesController.dispose();
  }
}
