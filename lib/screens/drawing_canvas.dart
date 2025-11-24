// lib/screens/drawing_canvas.dart - Drawing Canvas for Diary
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});
  
  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  List<DrawingPoint> drawingPoints = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;
  final GlobalKey _canvasKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E97FD),
        title: Text('Vẽ hình', style: GoogleFonts.afacad(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clear,
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Column(
        children: [
          // Canvas
          Expanded(
            child: RepaintBoundary(
              key: _canvasKey,
              child: Container(
                color: Colors.white,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      drawingPoints.add(
                        DrawingPoint(
                          offset: details.localPosition,
                          paint: Paint()
                            ..color = selectedColor
                            ..strokeWidth = strokeWidth
                            ..strokeCap = StrokeCap.round,
                        ),
                      );
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      drawingPoints.add(
                        DrawingPoint(
                          offset: details.localPosition,
                          paint: Paint()
                            ..color = selectedColor
                            ..strokeWidth = strokeWidth
                            ..strokeCap = StrokeCap.round,
                        ),
                      );
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      drawingPoints.add(DrawingPoint(offset: null, paint: null));
                    });
                  },
                  child: CustomPaint(
                    painter: DrawingPainter(drawingPoints),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          
          // Tools
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                // Stroke width
                Row(
                  children: [
                    Text('Độ dày: ', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: strokeWidth,
                        min: 1.0,
                        max: 20.0,
                        activeColor: const Color(0xFF8E97FD),
                        onChanged: (value) {
                          setState(() => strokeWidth = value);
                        },
                      ),
                    ),
                    Text('${strokeWidth.toInt()}', style: GoogleFonts.afacad()),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Colors
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildColorButton(Colors.black),
                      _buildColorButton(Colors.red),
                      _buildColorButton(Colors.blue),
                      _buildColorButton(Colors.green),
                      _buildColorButton(Colors.yellow),
                      _buildColorButton(Colors.orange),
                      _buildColorButton(Colors.purple),
                      _buildColorButton(Colors.pink),
                      _buildColorButton(Colors.brown),
                      _buildColorButton(Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildColorButton(Color color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFF8E97FD) : Colors.grey[400]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }
  
  void _undo() {
    if (drawingPoints.isNotEmpty) {
      setState(() {
        // Remove last stroke (until we hit a null point)
        while (drawingPoints.isNotEmpty && drawingPoints.last.offset != null) {
          drawingPoints.removeLast();
        }
        if (drawingPoints.isNotEmpty) {
          drawingPoints.removeLast(); // Remove the null separator
        }
      });
    }
  }
  
  void _clear() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text('Xóa hết?', style: GoogleFonts.afacad(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc muốn xóa toàn bộ bản vẽ?', style: GoogleFonts.afacad()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.afacad(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => drawingPoints.clear());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF5350)),
            child: Text('Xóa', style: GoogleFonts.afacad(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveDrawing() async {
    try {
      // Capture the drawing as an image
      final RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      
      // Save to file
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'drawing_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${appDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);
      
      // Return the file path
      if (mounted) {
        Navigator.pop(context, file.path);
      }
    } catch (e) {
      print('❌ Error saving drawing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lưu hình vẽ', style: GoogleFonts.afacad()),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    }
  }
}

// Drawing point model
class DrawingPoint {
  Offset? offset;
  Paint? paint;
  
  DrawingPoint({this.offset, this.paint});
}

// Custom painter
class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;
  
  DrawingPainter(this.drawingPoints);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < drawingPoints.length - 1; i++) {
      if (drawingPoints[i].offset != null && drawingPoints[i + 1].offset != null) {
        canvas.drawLine(
          drawingPoints[i].offset!,
          drawingPoints[i + 1].offset!,
          drawingPoints[i].paint!,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
