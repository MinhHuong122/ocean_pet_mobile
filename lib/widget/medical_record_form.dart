// lib/widget/medical_record_form.dart - Form to Create/Edit Medical Records
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalRecordForm extends StatefulWidget {
  final String title;
  final List<MedicalFormField> fields;
  final VoidCallback onSubmit;
  final Function(Map<String, dynamic>) onFormData;
  final String submitButtonText;
  final bool includePetSelection;
  final String? initialPetId;

  const MedicalRecordForm({
    super.key,
    required this.title,
    required this.fields,
    required this.onSubmit,
    required this.onFormData,
    this.submitButtonText = 'Lưu',
    this.includePetSelection = false,
    this.initialPetId,
  });

  @override
  State<MedicalRecordForm> createState() => _MedicalRecordFormState();
}

class _MedicalRecordFormState extends State<MedicalRecordForm> {
  late Map<String, TextEditingController> controllers;
  late Map<String, String?> selectedValues;
  final _formKey = GlobalKey<FormState>();
  
  // Pet selection
  List<Map<String, dynamic>> availablePets = [];
  String? selectedPetId;
  bool isLoadingPets = false;

  @override
  void initState() {
    super.initState();
    controllers = {};
    selectedValues = {};
    selectedPetId = widget.initialPetId;

    for (var field in widget.fields) {
      controllers[field.name] = TextEditingController(text: field.initialValue ?? '');
      if (field.type == FormFieldType.dropdown) {
        selectedValues[field.name] = field.initialValue;
      }
    }
    
    if (widget.includePetSelection) {
      _loadAvailablePets();
    }
  }

  // Load available pets from Firebase
  Future<void> _loadAvailablePets() async {
    try {
      setState(() {
        isLoadingPets = true;
      });
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoadingPets = false;
        });
        return;
      }
      
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('user_id', isEqualTo: user.uid)
          .get();
      
      setState(() {
        availablePets = petsSnapshot.docs
            .map((doc) => {
              'id': doc.id,
              'name': doc['name'] ?? 'Unknown Pet',
              'breed': doc['breed'] ?? 'Unknown',
              'age': _formatAge(doc['age']),
            })
            .toList();
        
        if (selectedPetId == null && availablePets.isNotEmpty) {
          selectedPetId = availablePets[0]['id'];
        }
        
        isLoadingPets = false;
      });
    } catch (e) {
      print('Error loading pets: $e');
      setState(() {
        isLoadingPets = false;
      });
    }
  }

  // Format age from months to years/months
  String _formatAge(dynamic age) {
    if (age is! int) {
      return (age ?? 'Unknown').toString();
    }
    
    if (age < 12) {
      return '$age tháng';
    } else {
      int years = age ~/ 12;
      int months = age % 12;
      if (months == 0) {
        return '$years năm';
      } else {
        return '$years năm $months tháng';
      }
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with title centered
          Container(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1.5)),
            ),
            child: Center(
              child: Text(
                widget.title,
                style: GoogleFonts.afacad(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Form Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Selection Field (if enabled)
                      if (widget.includePetSelection)
                        _buildPetSelectionField(),
                      
                      // Other fields
                      ...widget.fields.map((field) {
                        return _buildFormField(field);
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
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
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.submitButtonText,
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

  Widget _buildPetSelectionField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn thú cưng',
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoadingPets)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang tải danh sách thú cưng...',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else if (availablePets.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chưa có thú cưng nào. Vui lòng tạo thú cưng trước.',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedPetId,
                onChanged: (newValue) {
                  setState(() {
                    selectedPetId = newValue;
                  });
                },
                isExpanded: true,
                underline: const SizedBox(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                items: availablePets.map((pet) {
                  return DropdownMenuItem<String>(
                    value: pet['id'],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pet['name'],
                          style: GoogleFonts.afacad(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${pet['breed']} • ${pet['age']}',
                          style: GoogleFonts.afacad(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormField(MedicalFormField field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
      case FormFieldType.phone:
        return _buildTextInput(field);

      case FormFieldType.textarea:
        return _buildTextAreaInput(field);

      case FormFieldType.dropdown:
        return _buildDropdownInput(field);

      case FormFieldType.date:
        return _buildDateInput(field);

      case FormFieldType.multiselect:
        return _buildMultiSelectInput(field);
    }
  }

  Widget _buildTextInput(MedicalFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controllers[field.name],
            keyboardType: _getKeyboardType(field.type),
            decoration: InputDecoration(
              hintText: field.hint,
              hintStyle: GoogleFonts.afacad(
                fontSize: 13,
                color: Colors.grey[400],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.afacad(fontSize: 13),
            validator: (value) {
              if (field.required && (value == null || value.isEmpty)) {
                return '${field.label} không được để trống';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextAreaInput(MedicalFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controllers[field.name],
            maxLines: field.maxLines ?? 4,
            decoration: InputDecoration(
              hintText: field.hint,
              hintStyle: GoogleFonts.afacad(
                fontSize: 13,
                color: Colors.grey[400],
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: GoogleFonts.afacad(fontSize: 13),
            validator: (value) {
              if (field.required && (value == null || value.isEmpty)) {
                return '${field.label} không được để trống';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownInput(MedicalFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: DropdownButton<String>(
                value: selectedValues[field.name],
                hint: Text(
                  field.hint ?? 'Chọn ${field.label.toLowerCase()}',
                  style: GoogleFonts.afacad(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: field.options?.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        option,
                        style: GoogleFonts.afacad(
                          fontSize: 14,
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValues[field.name] = value;
                  });
                },
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  color: Colors.grey[900],
                  fontWeight: FontWeight.w500,
                ),
                dropdownColor: Colors.white,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF8B5CF6),
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(MedicalFormField field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(field),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controllers[field.name]!.text.isEmpty
                        ? 'Chọn ngày'
                        : controllers[field.name]!.text,
                    style: GoogleFonts.afacad(
                      fontSize: 13,
                      color: controllers[field.name]!.text.isEmpty
                          ? Colors.grey[400]
                          : Colors.black,
                    ),
                  ),
                  const Icon(Icons.calendar_today,
                      color: Color(0xFF8B5CF6), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectInput(MedicalFormField field) {
    List<String> selected =
        (selectedValues[field.name] ?? '').toString().split(',');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: field.options?.map((option) {
              bool isSelected = selected.contains(option);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selected.remove(option);
                    } else {
                      selected.add(option);
                    }
                    selectedValues[field.name] = selected.join(',');
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    option,
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList() ?? [],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(MedicalFormField field) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    );

    if (picked != null) {
      String formatted =
          '${picked.day}/${picked.month}/${picked.year}';
      setState(() {
        controllers[field.name]!.text = formatted;
      });
    }
  }

  TextInputType _getKeyboardType(FormFieldType type) {
    switch (type) {
      case FormFieldType.email:
        return TextInputType.emailAddress;
      case FormFieldType.phone:
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> formData = {};

      for (var field in widget.fields) {
        if (field.type == FormFieldType.dropdown ||
            field.type == FormFieldType.multiselect) {
          formData[field.name] = selectedValues[field.name] ?? '';
        } else {
          formData[field.name] = controllers[field.name]!.text;
        }
      }

      // Include selected pet ID if pet selection is enabled
      if (widget.includePetSelection && selectedPetId != null) {
        formData['pet_id'] = selectedPetId;
      }

      widget.onFormData(formData);
      widget.onSubmit();
    }
  }
}

class MedicalFormField {
  final String name;
  final String label;
  final FormFieldType type;
  final String? hint;
  final String? initialValue;
  final bool required;
  final List<String>? options;
  final int? maxLines;

  MedicalFormField({
    required this.name,
    required this.label,
    required this.type,
    this.hint,
    this.initialValue,
    this.required = false,
    this.options,
    this.maxLines,
  });
}

enum FormFieldType {
  text,
  email,
  phone,
  textarea,
  dropdown,
  date,
  multiselect,
}
