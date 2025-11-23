import 'package:flutter/material.dart';

/// Utility class để xử lý các vấn đề liên quan đến bàn phím
class KeyboardUtil {
  /// Ẩn bàn phím
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Kiểm tra xem bàn phím có đang hiển thị không
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Lấy chiều cao bàn phím
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Lấy chiều cao screen còn lại khi bàn phím hiển thị
  static double getAvailableHeight(BuildContext context) {
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
  }

  /// Build một TextField với xử lý keyboard tốt
  static Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    TextInputAction textInputAction = TextInputAction.done,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      minLines: maxLines == 1 ? 1 : maxLines,
      validator: validator,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
    );
  }
}

/// Widget wrapper để giải quyết vấn đề pixel khi keyboard hiển thị
class KeyboardAwareScaffold extends StatelessWidget {
  final AppBar? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const KeyboardAwareScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? Colors.white,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SingleChildScrollView(
        // Tự động scroll khi keyboard xuất hiện
        reverse: true,
        child: Padding(
          // Padding để tránh keyboard che phủ content
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Dialog cho phép input mà không bị keyboard che phủ
class KeyboardAwareDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String? Function(String?)? validator;
  final VoidCallback onCancel;
  final Function(String) onSubmit;
  final TextInputType keyboardType;
  final int maxLines;

  const KeyboardAwareDialog({
    Key? key,
    required this.title,
    required this.hintText,
    this.validator,
    required this.onCancel,
    required this.onSubmit,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              KeyboardUtil.buildInputField(
                controller: controller,
                hintText: hintText,
                validator: validator,
                keyboardType: keyboardType,
                maxLines: maxLines,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onCancel();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Vui lòng nhập $hintText')),
                        );
                        return;
                      }
                      onSubmit(controller.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Xác nhận'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget tự động resize khi keyboard xuất hiện
class AutoResizeWidget extends StatefulWidget {
  final Widget Function(BuildContext context, double availableHeight) builder;

  const AutoResizeWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<AutoResizeWidget> createState() => _AutoResizeWidgetState();
}

class _AutoResizeWidgetState extends State<AutoResizeWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = KeyboardUtil.getAvailableHeight(context);
    return widget.builder(context, availableHeight);
  }
}
