// lib/screens/pet_management_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PetManagementScreen extends StatefulWidget {
  const PetManagementScreen({super.key});

  @override
  State<PetManagementScreen> createState() => _PetManagementScreenState();
}

class _PetManagementScreenState extends State<PetManagementScreen> {
  List<Map<String, dynamic>> pets = [
    {
      'id': '1',
      'name': 'Mochi',
      'type': 'Mèo Ba Tư',
      'age': '2 tuổi',
      'gender': 'Cái',
      'weight': '3.5 kg',
      'color': 'Trắng',
      'imagePath': null,
    },
    {
      'id': '2',
      'name': 'Lucky',
      'type': 'Chó Golden',
      'age': '3 tuổi',
      'gender': 'Đực',
      'weight': '25 kg',
      'color': 'Vàng',
      'imagePath': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E97FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quản lý thú cưng',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có thú cưng nào',
                    style: GoogleFonts.afacad(
                      fontSize: 18,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return _buildPetCard(pet);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditPetDialog(),
        backgroundColor: const Color(0xFF8E97FD),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Thêm thú cưng',
          style: GoogleFonts.afacad(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E97FD).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showAddEditPetDialog(pet: pet),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pet avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF8E97FD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: pet['imagePath'] != null
                      ? DecorationImage(
                          image: FileImage(File(pet['imagePath'])),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: pet['imagePath'] == null
                    ? const Icon(
                        Icons.pets,
                        size: 40,
                        color: Color(0xFF8E97FD),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'],
                      style: GoogleFonts.afacad(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet['type']} • ${pet['age']}',
                      style: GoogleFonts.afacad(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          pet['gender'] == 'Đực' ? Icons.male : Icons.female,
                          size: 16,
                          color: const Color(0xFF8E97FD),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pet['gender']} • ${pet['weight']}',
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Color(0xFF8E97FD)),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditPetDialog(pet: pet);
                  } else if (value == 'delete') {
                    _confirmDeletePet(pet);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, color: Color(0xFF8E97FD)),
                        const SizedBox(width: 8),
                        Text('Chỉnh sửa', style: GoogleFonts.afacad()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Color(0xFFEF5350)),
                        const SizedBox(width: 8),
                        Text('Xóa', style: GoogleFonts.afacad()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEditPetDialog({Map<String, dynamic>? pet}) {
    final isEdit = pet != null;
    final nameController = TextEditingController(text: pet?['name'] ?? '');
    final typeController = TextEditingController(text: pet?['type'] ?? '');
    final ageController = TextEditingController(text: pet?['age'] ?? '');
    final weightController = TextEditingController(text: pet?['weight'] ?? '');
    final colorController = TextEditingController(text: pet?['color'] ?? '');
    String selectedGender = pet?['gender'] ?? 'Đực';
    String? imagePath = pet?['imagePath'];
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEdit ? 'Chỉnh sửa thú cưng' : 'Thêm thú cưng mới',
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8E97FD),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pet image picker
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          setDialogState(() {
                            imagePath = image.path;
                          });
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E97FD).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          image: imagePath != null
                              ? DecorationImage(
                                  image: FileImage(File(imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imagePath == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Color(0xFF8E97FD),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Thêm ảnh',
                                    style: GoogleFonts.afacad(
                                      color: const Color(0xFF8E97FD),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên thú cưng *',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.pets),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(
                        labelText: 'Giống loài *',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'VD: Mèo Ba Tư, Chó Golden',
                        prefixIcon: const Icon(Icons.category),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            decoration: InputDecoration(
                              labelText: 'Tuổi',
                              labelStyle: GoogleFonts.afacad(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'VD: 2 tuổi',
                              prefixIcon: const Icon(Icons.cake),
                            ),
                            style: GoogleFonts.afacad(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Giới tính',
                              labelStyle: GoogleFonts.afacad(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: ['Đực', 'Cái'].map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child:
                                    Text(gender, style: GoogleFonts.afacad()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedGender = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Cân nặng',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'VD: 3.5 kg',
                        prefixIcon: const Icon(Icons.monitor_weight),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: colorController,
                      decoration: InputDecoration(
                        labelText: 'Màu lông',
                        labelStyle: GoogleFonts.afacad(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'VD: Trắng, Vàng',
                        prefixIcon: const Icon(Icons.palette),
                      ),
                      style: GoogleFonts.afacad(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: GoogleFonts.afacad(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        typeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Vui lòng điền đầy đủ thông tin bắt buộc'),
                          backgroundColor: const Color(0xFFEF5350),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (isEdit) {
                        pet['name'] = nameController.text;
                        pet['type'] = typeController.text;
                        pet['age'] = ageController.text;
                        pet['gender'] = selectedGender;
                        pet['weight'] = weightController.text;
                        pet['color'] = colorController.text;
                        pet['imagePath'] = imagePath;
                      } else {
                        pets.add({
                          'id':
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': nameController.text,
                          'type': typeController.text,
                          'age': ageController.text,
                          'gender': selectedGender,
                          'weight': weightController.text,
                          'color': colorController.text,
                          'imagePath': imagePath,
                        });
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEdit
                              ? '✅ Đã cập nhật ${nameController.text}'
                              : '✅ Đã thêm ${nameController.text}',
                        ),
                        backgroundColor: const Color(0xFF66BB6A),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E97FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEdit ? 'Cập nhật' : 'Thêm',
                    style: GoogleFonts.afacad(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeletePet(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Xóa thú cưng',
            style: GoogleFonts.afacad(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEF5350),
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa ${pet['name']}?',
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
                  pets.removeWhere((p) => p['id'] == pet['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa ${pet['name']}'),
                    backgroundColor: const Color(0xFFEF5350),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xóa',
                style: GoogleFonts.afacad(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
