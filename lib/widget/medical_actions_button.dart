// lib/widgets/medical_actions_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalActionsButton extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onShareWhatsApp;
  final VoidCallback onShareZalo;
  final VoidCallback? onShareEmail;
  final bool isLoading;

  const MedicalActionsButton({
    Key? key,
    required this.onExportPDF,
    required this.onShareWhatsApp,
    required this.onShareZalo,
    this.onShareEmail,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Primary action: Export PDF
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onExportPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.file_download),
              label: Text(
                isLoading ? 'Đang xuất...' : 'Xuất PDF Hồ Sơ',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Secondary actions: Share buttons
          Row(
            children: [
              // WhatsApp
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onShareWhatsApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.chat, size: 18),
                  label: Text(
                    'WhatsApp',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Zalo
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onShareZalo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0084FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.mail, size: 18),
                  label: Text(
                    'Zalo',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (onShareEmail != null) ...[
                const SizedBox(width: 8),
                // Email
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onShareEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA4335),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.email, size: 18),
                    label: Text(
                      'Email',
                      style: GoogleFonts.afacad(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact version for inline use
class MedicalActionsButtonCompact extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onShare;
  final bool isLoading;

  const MedicalActionsButtonCompact({
    Key? key,
    required this.onExportPDF,
    required this.onShare,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onExportPDF,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, size: 16),
            label: Text(
              'PDF',
              style: GoogleFonts.afacad(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onShare,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.share, size: 16),
            label: Text(
              'Chia sẻ',
              style: GoogleFonts.afacad(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
