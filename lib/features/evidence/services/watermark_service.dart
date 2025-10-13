import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Service for applying tamper-evident watermarks to evidence files
class WatermarkService {
  static const String _watermarkFont = 'Arial';
  static const double _watermarkOpacity = 0.7;
  static const Color _watermarkColor = Colors.white;

  /// Apply watermark to an image file using Flutter's canvas
  static Future<Uint8List> applyWatermarkToImage(
    Uint8List imageBytes,
    String projectId,
    String uploaderName,
    DateTime timestamp,
  ) async {
    // Decode image using Flutter's codec
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final originalImage = frameInfo.image;

    // Create watermark text
    final watermarkText = _createWatermarkText(projectId, uploaderName, timestamp);
    
    // Apply watermark using Flutter canvas
    final watermarkedImage = await _overlayTextWatermarkCanvas(
      originalImage,
      watermarkText,
      position: WatermarkPosition.bottomRight,
    );

    final byteData = await watermarkedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Apply watermark to document (PDF/etc) - creates overlay image
  static Future<Uint8List> applyWatermarkToDocument(
    Uint8List documentBytes,
    String projectId,
    String uploaderName,
    DateTime timestamp,
  ) async {
    // For documents, create a watermark overlay image
    final watermarkText = _createWatermarkText(projectId, uploaderName, timestamp);
    final watermarkImage = await _createWatermarkOverlay(watermarkText);
    
    return watermarkImage;
  }

  /// Lock EXIF metadata to prevent tampering
  static Map<String, dynamic> lockExifMetadata(
    Map<String, dynamic> originalExif,
    String projectId,
    String uploaderName,
    DateTime timestamp,
    double? latitude,
    double? longitude,
  ) {
    final lockedExif = Map<String, dynamic>.from(originalExif);
    
    // Add tamper-evident EXIF fields
    lockedExif['ProjectID'] = projectId;
    lockedExif['UploaderName'] = uploaderName;
    lockedExif['LockTimestamp'] = timestamp.toIso8601String();
    lockedExif['TamperSeal'] = _generateTamperSeal(projectId, uploaderName, timestamp);
    
    // Lock GPS coordinates if available
    if (latitude != null && longitude != null) {
      lockedExif['GPS_Latitude'] = latitude;
      lockedExif['GPS_Longitude'] = longitude;
      lockedExif['GPS_Locked'] = true;
    }
    
    // Add integrity hash
    lockedExif['IntegrityHash'] = _generateIntegrityHash(lockedExif);
    
    return lockedExif;
  }

  /// Verify watermark integrity (simplified for Flutter implementation)
  static bool verifyWatermarkIntegrity(
    Uint8List imageBytes,
    String expectedProjectId,
    String expectedUploader,
    DateTime expectedTimestamp,
  ) {
    try {
      // Simplified verification - check if image has watermark metadata
      final expectedWatermark = _createWatermarkText(
        expectedProjectId,
        expectedUploader,
        expectedTimestamp,
      );

      // In production, implement proper watermark extraction and comparison
      return imageBytes.isNotEmpty && expectedWatermark.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verify EXIF lock integrity
  static bool verifyExifLockIntegrity(Map<String, dynamic> exifData) {
    try {
      final storedHash = exifData['IntegrityHash'] as String?;
      if (storedHash == null) return false;

      final exifCopy = Map<String, dynamic>.from(exifData);
      exifCopy.remove('IntegrityHash');
      
      final calculatedHash = _generateIntegrityHash(exifCopy);
      return storedHash == calculatedHash;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  static String _createWatermarkText(String projectId, String uploader, DateTime timestamp) {
    final formattedDate = '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
    
    return 'PROJECT: $projectId\nUPLOADED: $uploader\nDATE: $formattedDate\nTAMPER-EVIDENT';
  }

  static Future<ui.Image> _overlayTextWatermarkCanvas(
    ui.Image originalImage,
    String text,
    {required WatermarkPosition position}
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(originalImage.width.toDouble(), originalImage.height.toDouble());

    // Draw original image
    canvas.drawImage(originalImage, Offset.zero, Paint());

    // Prepare watermark text
    final lines = text.split('\n');
    final fontSize = (originalImage.width * 0.015).clamp(10.0, 18.0);
    
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.8),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );

    // Calculate position
    double x, y;
    const padding = 20.0;
    final textHeight = lines.length * fontSize * 1.4;
    
    switch (position) {
      case WatermarkPosition.bottomRight:
        x = size.width - 280 - padding;
        y = size.height - textHeight - padding;
        break;
      case WatermarkPosition.bottomLeft:
        x = padding;
        y = size.height - textHeight - padding;
        break;
      case WatermarkPosition.topRight:
        x = size.width - 280 - padding;
        y = padding;
        break;
      case WatermarkPosition.topLeft:
        x = padding;
        y = padding;
        break;
    }

    // Draw semi-transparent background
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 10, y - 10, 280, textHeight + 20),
        const Radius.circular(5),
      ),
      backgroundPaint,
    );

    // Draw text lines
    for (int i = 0; i < lines.length; i++) {
      final textSpan = TextSpan(text: lines[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, y + (i * fontSize * 1.4)));
    }

    final picture = recorder.endRecording();
    return await picture.toImage(originalImage.width, originalImage.height);
  }

  static Future<Uint8List> _createWatermarkOverlay(String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(400, 200);

    // Draw semi-transparent background
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw watermark text
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: size.width - 20);
    textPainter.paint(canvas, const Offset(10, 10));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  static String _generateTamperSeal(String projectId, String uploader, DateTime timestamp) {
    final data = '$projectId:$uploader:${timestamp.millisecondsSinceEpoch}';
    return data.hashCode.toRadixString(16).toUpperCase();
  }

  static String _generateIntegrityHash(Map<String, dynamic> data) {
    final sortedKeys = data.keys.toList()..sort();
    final hashString = sortedKeys.map((key) => '$key:${data[key]}').join('|');
    return hashString.hashCode.toRadixString(16).toUpperCase();
  }
}

enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Watermark metadata for evidence files
class WatermarkMetadata {
  final String projectId;
  final String uploaderName;
  final DateTime timestamp;
  final WatermarkPosition position;
  final bool isLocked;
  final Map<String, dynamic> exifData;

  const WatermarkMetadata({
    required this.projectId,
    required this.uploaderName,
    required this.timestamp,
    required this.position,
    required this.isLocked,
    required this.exifData,
  });

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'uploaderName': uploaderName,
    'timestamp': timestamp.toIso8601String(),
    'position': position.name,
    'isLocked': isLocked,
    'exifData': exifData,
  };

  factory WatermarkMetadata.fromJson(Map<String, dynamic> json) => WatermarkMetadata(
    projectId: json['projectId'],
    uploaderName: json['uploaderName'],
    timestamp: DateTime.parse(json['timestamp']),
    position: WatermarkPosition.values.firstWhere((p) => p.name == json['position']),
    isLocked: json['isLocked'],
    exifData: json['exifData'],
  );
}