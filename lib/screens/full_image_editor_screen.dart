import 'dart:io';
import 'package:docexaaesthetic/Repository/PatientRepository';
import 'package:docexaaesthetic/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

enum DrawMode { freehand, rectangle, circle }

class FullImageEditorScreen extends StatefulWidget {
  // final File image;
  final dynamic image;
  final String? uploadedDate;
  final String? patientNumber;
  final int? patientId;
  final String? doctorId;

  const FullImageEditorScreen(
      {required this.image,
      this.uploadedDate,
      this.patientNumber,
      this.patientId,
      this.doctorId,
      Key? key})
      : super(key: key);

  @override
  State<FullImageEditorScreen> createState() => _FullImageEditorScreenState();
}

class _FullImageEditorScreenState extends State<FullImageEditorScreen> {
  final TransformationController _transformationController =
      TransformationController();
  bool isMarkingEnabled = false;
  final GlobalKey _imageKey = GlobalKey();
  final String userLogin = 'gajendra82'; // Added user login
  final String timestamp = '2025-05-27 07:25:45'; // Added timestamp

  List<Offset?> points = [];
  List<ShapeDraw> shapes = [];
  Color selectedColor = Colors.red;
  DrawMode currentMode = DrawMode.freehand;
  Offset? startShape;
  Offset? endShape;
  Size? _imageSize;
  double _viewportWidth = 0;
  double _viewportHeight = 0;
  final apiService = ApiService();
  late final PatientRepository patientRepository;

  @override
  void initState() {
    super.initState();
    patientRepository = PatientRepository(apiService);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateImageSize();
    });
  }

  void _updateImageSize() {
    final RenderBox? renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() => selectedColor = color);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _clearDrawing() {
    setState(() {
      points.clear();
      shapes.clear();
    });
  }

  Future<void> _saveAndUploadMarkedImage(BuildContext context) async {
    try {
      RenderRepaintBoundary boundary =
          _imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

      if (boundary == null) throw Exception('Unable to find repaint boundary!');

      // Capture image as PNG bytes
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null)
        throw Exception('Unable to convert image to bytes!');

      // Save to a temp file
      final directory = await getTemporaryDirectory();
      final String fileName =
          'marked_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';
      File imgFile = File(filePath);
      await imgFile.writeAsBytes(byteData.buffer.asUint8List());

      // TODO: Replace these with actual values or pass via widget
      String? doctorId = widget.doctorId;
      String patientId = widget.patientId?.toString() ?? 'default_patient_id';
      String patientNumber = widget.patientNumber ?? 'default_patient_id';

      // Call repository to upload
      // You'll need access to your repository instance here, pass it via widget or use Provider
      final response = await patientRepository.uploadMarkedPatientImages(
        imageFiles: [imgFile],
        doctorId: doctorId ?? 'default_doctor_id',
        patientId: patientId,
        patientNumber: patientNumber,
        ismarked: "1",
      );

      if (response.status) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        setState(() {
          isMarkingEnabled = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${response.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Offset _transformToImageSpace(Offset globalPosition) {
    if (_imageSize == null) return globalPosition;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);

    // Get the widget's size
    final Size widgetSize = box.size;

    // Calculate the scale and translation from the transformation matrix
    final Matrix4 transform = _transformationController.value;
    final double scale = transform.getMaxScaleOnAxis();

    // Get translation from the matrix
    final double translateX = transform.getTranslation().x;
    final double translateY = transform.getTranslation().y;

    // Calculate the position relative to the image
    double x = (localPosition.dx - translateX) / scale;
    double y = (localPosition.dy - translateY) / scale;

    // Adjust for image centering
    if (_imageSize!.width < widgetSize.width) {
      x -= (widgetSize.width - _imageSize!.width) / (2 * scale);
    }
    if (_imageSize!.height < widgetSize.height) {
      y -= (widgetSize.height - _imageSize!.height) / (2 * scale);
    }

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Zoom and Mark",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          if (isMarkingEnabled) ...[
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: _showColorPicker,
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearDrawing,
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // User info and timestamp header
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User: $userLogin',
                    style: const TextStyle(color: Colors.teal)),
                Text(widget.uploadedDate ?? 'Not available',
                    style: const TextStyle(color: Colors.teal)),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewportWidth = constraints.maxWidth;
                _viewportHeight = constraints.maxHeight;
                return ClipRect(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: !isMarkingEnabled,
                    scaleEnabled: !isMarkingEnabled,
                    minScale: 0.5,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(0),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: isMarkingEnabled
                          ? (details) {
                              final localPos = _transformToImageSpace(
                                  details.globalPosition);
                              setState(() {
                                if (currentMode == DrawMode.freehand) {
                                  points.add(localPos);
                                } else {
                                  startShape = localPos;
                                }
                              });
                            }
                          : null,
                      onPanUpdate: isMarkingEnabled
                          ? (details) {
                              final localPos = _transformToImageSpace(
                                  details.globalPosition);
                              setState(() {
                                if (currentMode == DrawMode.freehand) {
                                  points.add(localPos);
                                } else {
                                  endShape = localPos;
                                }
                              });
                            }
                          : null,
                      onPanEnd: isMarkingEnabled
                          ? (_) {
                              setState(() {
                                if (currentMode != DrawMode.freehand &&
                                    startShape != null &&
                                    endShape != null) {
                                  shapes.add(ShapeDraw(
                                    color: selectedColor,
                                    start: startShape!,
                                    end: endShape!,
                                    mode: currentMode,
                                  ));
                                }
                                points.add(null);
                                startShape = null;
                                endShape = null;
                              });
                            }
                          : null,
                      child: RepaintBoundary(
                        key: _imageKey,
                        child: Stack(
                          children: [
                            Center(
                              child: widget.image is File
                                  ? Image.file(widget.image as File,
                                      fit: BoxFit.contain)
                                  : Image.network(
                                      widget.image as String,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            if (_imageSize != null)
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: ShapePainter(
                                    points: points,
                                    shapes: shapes,
                                    tempShape:
                                        (startShape != null && endShape != null)
                                            ? ShapeDraw(
                                                color: selectedColor,
                                                start: startShape!,
                                                end: endShape!,
                                                mode: currentMode,
                                              )
                                            : null,
                                    viewportSize:
                                        Size(_viewportWidth, _viewportHeight),
                                    imageSize: _imageSize!,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.teal.shade50,
        child: isMarkingEnabled
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _shapeButton(Icons.edit, "Free", DrawMode.freehand),
                      const SizedBox(width: 8),
                      _shapeButton(
                          Icons.crop_square, "Rectangle", DrawMode.rectangle),
                      const SizedBox(width: 8),
                      _shapeButton(Icons.circle, "Circle", DrawMode.circle),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.save, color: Colors.green),
                        label: const Text(
                          "Save & Upload",
                          style: TextStyle(color: Colors.green),
                        ),
                        onPressed: () => _saveAndUploadMarkedImage(context),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          "Stop Marking",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () =>
                            setState(() => isMarkingEnabled = false),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Start Marking",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  onPressed: () => setState(() => isMarkingEnabled = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _shapeButton(IconData icon, String label, DrawMode mode) {
    final isSelected = currentMode == mode;
    return TextButton.icon(
      onPressed: () => setState(() => currentMode = mode),
      icon: Icon(
        icon,
        color: isSelected ? Colors.teal : Colors.grey.shade600,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.teal : Colors.grey.shade600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class ShapeDraw {
  final Offset start;
  final Offset end;
  final Color color;
  final DrawMode mode;

  ShapeDraw(
      {required this.start,
      required this.end,
      required this.color,
      required this.mode});
}

class ShapePainter extends CustomPainter {
  final List<Offset?> points;
  final List<ShapeDraw> shapes;
  final ShapeDraw? tempShape;
  final Size viewportSize;
  final Size imageSize;

  ShapePainter({
    required this.points,
    required this.shapes,
    this.tempShape,
    required this.viewportSize,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Calculate scaling and translation to fit image in viewport
    final double scale = math.min(
      viewportSize.width / imageSize.width,
      viewportSize.height / imageSize.height,
    );

    final double dx = (viewportSize.width - imageSize.width * scale) / 2;
    final double dy = (viewportSize.height - imageSize.height * scale) / 2;

    // Draw freehand points
    paint.color = Colors.red;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }

    // Draw saved shapes
    for (final shape in shapes) {
      paint.color = shape.color;
      _drawShape(canvas, paint, shape.start, shape.end, shape.mode);
    }

    // Draw temporary shape
    if (tempShape != null) {
      paint.color = tempShape!.color;
      _drawShape(
          canvas, paint, tempShape!.start, tempShape!.end, tempShape!.mode);
    }
  }

  void _drawShape(
      Canvas canvas, Paint paint, Offset start, Offset end, DrawMode mode) {
    switch (mode) {
      case DrawMode.rectangle:
        canvas.drawRect(Rect.fromPoints(start, end), paint);
        break;
      case DrawMode.circle:
        final center = Offset(
          (start.dx + end.dx) / 2,
          (start.dy + end.dy) / 2,
        );
        final radius = (end - start).distance / 2;
        canvas.drawCircle(center, radius, paint);
        break;
      case DrawMode.freehand:
        // Handled separately for points
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
