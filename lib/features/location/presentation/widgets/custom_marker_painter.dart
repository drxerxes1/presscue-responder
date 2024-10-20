import 'package:flutter/material.dart';
import 'package:presscue_patroller/core/constants/app_colors.dart';
import 'dart:ui' as ui;

class MarkerPainter extends CustomPainter {

  final ui.Image? image;
  MarkerPainter({required this.image});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final markerPaint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    final markerBorderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final markerBorderPaint2 = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw the marker circle in the center
    final markerRadius = size.width / 4;
    canvas.drawCircle(center, markerRadius, markerPaint);
    canvas.drawCircle(center, markerRadius, markerBorderPaint);

    // Draw the icon
    // canvas.drawPath(path, paint);

    // Draw the second inner circle beside the first one
    final markerRadius2 =
        size.width / 1; // Smaller radius for the second circle
    final offset = 1.5 * markerRadius; // Space between the circles
    final secondCircleCenter = center +
        Offset(
            0,
            -offset -
                30); // Position the second circle to the right of the first one
    canvas.drawCircle(secondCircleCenter, markerRadius2, markerPaint);
    canvas.drawCircle(secondCircleCenter, markerRadius2, markerBorderPaint2);

    final Paint paint = Paint()
      ..color = AppColors.primaryColor
      ..style = PaintingStyle.fill;

    final path = ui.Path();

    // Define the vertices of the downward-facing triangle
    final Offset vertex1 =
        Offset(size.width / 2, size.height - 15); // Bottom-center vertex
    final Offset vertex2 = Offset(7, 3); // Top-left vertex
    final Offset vertex3 = Offset(size.width - 7, 3); // Top-right vertex

    // Move to the first vertex
    path.moveTo(vertex1.dx, vertex1.dy);
    // Draw lines to the other vertices
    path.lineTo(vertex2.dx, vertex2.dy);
    path.lineTo(vertex3.dx, vertex3.dy);
    // Close the path to connect back to the starting point
    path.close();

    // Draw the triangle on the canvas
    canvas.drawPath(path, paint);

    if (image != null) {
      final Rect imageRect = Rect.fromCenter(
        center: secondCircleCenter,
        width: markerRadius2 * 2,
        height: markerRadius2 * 2,
      );
      final Paint imagePaint = Paint();
      canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        imageRect,
        imagePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
