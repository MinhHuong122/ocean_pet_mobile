// lib/widget/medical_record_detail_modal.dart - Enhanced Medical Record Detail View
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalRecordDetailModal extends StatefulWidget {
  final String title;
  final Map<String, dynamic> data;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final List<DetailField> fields;

  const MedicalRecordDetailModal({
    super.key,
    required this.title,
    required this.data,
    required this.fields,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MedicalRecordDetailModal> createState() => _MedicalRecordDetailModalState();
}

class _MedicalRecordDetailModalState extends State<MedicalRecordDetailModal> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final modalHeight = screenHeight * 2 / 3;

    return Container(
      height: modalHeight,
      width: screenWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),

          // Header with Title and Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.afacad(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 16),
                // Action Buttons Container
                Container(
                  child: Row(
                    children: [
                      if (widget.onEdit != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onEdit?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF8B5CF6),
                              size: 22,
                            ),
                          ),
                        ),
                      if (widget.onEdit != null && widget.onDelete != null)
                        const SizedBox(width: 10),
                      if (widget.onDelete != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onDelete?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF44336).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFFF44336),
                              size: 22,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1.5,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.fields.map((field) => _buildDetailField(field)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey[100]!,
                  width: 2,
                ),
              ),
              color: Colors.white,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Đóng',
                  style: GoogleFonts.afacad(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailField(DetailField field) {
    final displayValue = field.value?.toString() ?? 'Không có dữ liệu';
    final isNull = field.value == null || field.value.toString().isEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.afacad(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[220]!,
                width: 1.2,
              ),
            ),
            child: Text(
              displayValue,
              style: GoogleFonts.afacad(
                fontSize: 15,
                color: isNull ? Colors.grey[500] : Colors.grey[900],
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DetailField {
  final String label;
  final String? value;

  DetailField({required this.label, required this.value});
}
