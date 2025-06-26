import 'package:flutter/material.dart';
import '../models/preferred_position.dart';

/// A custom painter that draws the tooltip shape with an arrow.
///
/// This painter is responsible for drawing the tooltip's background, border,
/// and arrow in the specified position. It handles different positions (above,
/// below, left, right) and applies the appropriate styling.
class CustomTooltipShapePainter extends CustomPainter {
  /// The background color of the tooltip.
  final Color backgroundColor;

  /// The color of the tooltip's border.
  final Color borderColor;

  /// The width of the tooltip's border.
  final double borderWidth;

  /// The border radius of the tooltip's corners.
  final Radius borderRadius;

  /// The size of the arrow pointing to the target widget.
  final double arrowSize;

  /// Optional box shadows to apply to the tooltip.
  final List<BoxShadow>? boxShadow;

  /// The position of the tooltip relative to the target widget.
  final PreferredPosition position;

  /// The offset of the arrow from the left or top edge of the tooltip.
  /// This is used to position the arrow correctly relative to the target widget.
  final double arrowOffset;

  /// Creates a custom painter for the tooltip shape.
  ///
  /// All parameters are required to properly draw the tooltip with the desired
  /// appearance and positioning.
  CustomTooltipShapePainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.arrowSize,
    this.boxShadow,
    required this.position,
    required this.arrowOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create paint objects for filling and border
    final Paint fillPaint = Paint()..color = backgroundColor;
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Calculate arrow dimensions
    final double arrowWidth = arrowSize * 2;
    final double arrowHalfWidth = arrowWidth / 2;

    // Create path for tooltip shape based on position
    Path path = Path();
    switch (position) {
      case PreferredPosition.below:
        _paintBelowPath(path, size, arrowWidth, arrowHalfWidth, arrowOffset);
        break;
      case PreferredPosition.above:
        _paintAbovePath(path, size, arrowWidth, arrowHalfWidth, arrowOffset);
        break;
      case PreferredPosition.left:
        _paintLeftPath(path, size, arrowWidth, arrowHalfWidth, arrowOffset);
        break;
      case PreferredPosition.right:
        _paintRightPath(path, size, arrowWidth, arrowHalfWidth, arrowOffset);
        break;
    }

    // Draw shadows if provided
    if (boxShadow != null) {
      for (final shadow in boxShadow!) {
        final shadowPath = path.shift(shadow.offset);
        final shadowPaint = Paint()
          ..color = shadow.color.withValues(alpha: shadow.color.a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
        canvas.drawPath(shadowPath, shadowPaint);
      }
    }

    // Draw the main tooltip shape
    canvas.drawPath(path, fillPaint);

    // Draw border if border width is greater than 0
    if (borderWidth > 0.001) {
      canvas.drawPath(path, borderPaint);
    }
  }

  /// Paints the tooltip path for the "below" position.
  /// The arrow points upward from the top of the tooltip.
  void _paintBelowPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    // Define the main body rectangle (excluding arrow space)
    final Rect bodyRect = Rect.fromLTWH(
      0,
      arrowSize, // Start below the arrow
      size.width,
      size.height - arrowSize,
    );

    // Start drawing from the top-left corner
    path.moveTo(bodyRect.left + borderRadius.x, bodyRect.top);

    // Draw arrow if it fits within the tooltip bounds
    if (arrowOffset - arrowHalfWidth > bodyRect.left + borderRadius.x) {
      path.lineTo(arrowOffset - arrowHalfWidth, bodyRect.top);
      path.lineTo(arrowOffset, bodyRect.top - arrowSize); // Arrow tip
      path.lineTo(arrowOffset + arrowHalfWidth, bodyRect.top);
    }

    // Continue with the top edge
    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.top);

    // Draw rounded corners and remaining edges
    path.arcToPoint(
      Offset(bodyRect.right, bodyRect.top + borderRadius.y),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.right, bodyRect.bottom - borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.right - borderRadius.x, bodyRect.bottom),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.left + borderRadius.x, bodyRect.bottom);
    path.arcToPoint(
      Offset(bodyRect.left, bodyRect.bottom - borderRadius.y),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.left, bodyRect.top + borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.left + borderRadius.x, bodyRect.top),
      radius: borderRadius,
      clockwise: true,
    );
    path.close();
  }

  /// Paints the tooltip path for the "above" position.
  /// The arrow points downward from the bottom of the tooltip.
  void _paintAbovePath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    // Define the main body rectangle (excluding arrow space)
    final Rect bodyRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height - arrowSize,
    );

    // Start drawing from the bottom-left corner
    path.moveTo(bodyRect.left + borderRadius.x, bodyRect.bottom);

    // Draw arrow if it fits within the tooltip bounds
    if (arrowOffset - arrowHalfWidth > bodyRect.left + borderRadius.x) {
      path.lineTo(arrowOffset - arrowHalfWidth, bodyRect.bottom);
      path.lineTo(arrowOffset, bodyRect.bottom + arrowSize); // Arrow tip
      path.lineTo(arrowOffset + arrowHalfWidth, bodyRect.bottom);
    }

    // Continue with the bottom edge
    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.bottom);

    // Draw rounded corners and remaining edges
    path.arcToPoint(
      Offset(bodyRect.right, bodyRect.bottom - borderRadius.y),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.right, bodyRect.top + borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.right - borderRadius.x, bodyRect.top),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.left + borderRadius.x, bodyRect.top);
    path.arcToPoint(
      Offset(bodyRect.left, bodyRect.top + borderRadius.y),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.left, bodyRect.bottom - borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.left + borderRadius.x, bodyRect.bottom),
      radius: borderRadius,
      clockwise: false,
    );
    path.close();
  }

  /// Paints the tooltip path for the "left" position.
  /// The arrow points rightward from the right side of the tooltip.
  void _paintLeftPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    // Define the main body rectangle (excluding arrow space)
    final Rect bodyRect = Rect.fromLTWH(
      arrowSize, // Start after the arrow
      0,
      size.width - arrowSize,
      size.height,
    );

    // Start drawing from the top-left corner
    path.moveTo(bodyRect.left, bodyRect.top + borderRadius.y);

    // Draw arrow if it fits within the tooltip bounds
    if (arrowOffset - arrowHalfWidth > bodyRect.top + borderRadius.y) {
      path.lineTo(bodyRect.left, arrowOffset - arrowHalfWidth);
      path.lineTo(bodyRect.left - arrowSize, arrowOffset); // Arrow tip
      path.lineTo(bodyRect.left, arrowOffset + arrowHalfWidth);
    }

    // Continue with the left edge
    path.lineTo(bodyRect.left, bodyRect.bottom - borderRadius.y);

    // Draw rounded corners and remaining edges
    path.arcToPoint(
      Offset(bodyRect.left + borderRadius.x, bodyRect.bottom),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.bottom);
    path.arcToPoint(
      Offset(bodyRect.right, bodyRect.bottom - borderRadius.y),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.right, bodyRect.top + borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.right - borderRadius.x, bodyRect.top),
      radius: borderRadius,
      clockwise: true,
    );

    path.lineTo(bodyRect.left + borderRadius.x, bodyRect.top);
    path.arcToPoint(
      Offset(bodyRect.left, bodyRect.top + borderRadius.y),
      radius: borderRadius,
      clockwise: true,
    );
    path.close();
  }

  /// Paints the tooltip path for the "right" position.
  /// The arrow points leftward from the left side of the tooltip.
  void _paintRightPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    // Define the main body rectangle (excluding arrow space)
    final Rect bodyRect = Rect.fromLTWH(
      0,
      0,
      size.width - arrowSize,
      size.height,
    );

    // Start drawing from the top-right corner
    path.moveTo(bodyRect.right, bodyRect.top + borderRadius.y);

    // Draw arrow if it fits within the tooltip bounds
    if (arrowOffset - arrowHalfWidth > bodyRect.top + borderRadius.y) {
      path.lineTo(bodyRect.right, arrowOffset - arrowHalfWidth);
      path.lineTo(bodyRect.right + arrowSize, arrowOffset); // Arrow tip
      path.lineTo(bodyRect.right, arrowOffset + arrowHalfWidth);
    }

    // Continue with the right edge
    path.lineTo(bodyRect.right, bodyRect.bottom - borderRadius.y);

    // Draw rounded corners and remaining edges
    path.arcToPoint(
      Offset(bodyRect.right - borderRadius.x, bodyRect.bottom),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.left + borderRadius.x, bodyRect.bottom);
    path.arcToPoint(
      Offset(bodyRect.left, bodyRect.bottom - borderRadius.y),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.left, bodyRect.top + borderRadius.y);
    path.arcToPoint(
      Offset(bodyRect.left + borderRadius.x, bodyRect.top),
      radius: borderRadius,
      clockwise: false,
    );

    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.top);
    path.arcToPoint(
      Offset(bodyRect.right, bodyRect.top + borderRadius.y),
      radius: borderRadius,
      clockwise: false,
    );
    path.close();
  }

  @override
  bool shouldRepaint(CustomTooltipShapePainter oldDelegate) {
    // Only repaint if any of the visual properties have changed
    return backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        borderRadius != oldDelegate.borderRadius ||
        arrowSize != oldDelegate.arrowSize ||
        boxShadow != oldDelegate.boxShadow ||
        position != oldDelegate.position ||
        arrowOffset != oldDelegate.arrowOffset;
  }
}
