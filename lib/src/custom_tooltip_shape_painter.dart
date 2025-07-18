import 'package:flutter/material.dart';
import 'preferred_position.dart';

class CustomTooltipShapePainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Radius borderRadius;
  final double arrowSize;
  final List<BoxShadow>? boxShadow;
  final PreferredPosition position;
  final double arrowOffset;

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
    final Paint fillPaint = Paint()..color = backgroundColor;
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double arrowWidth = arrowSize * 2;
    final double arrowHalfWidth = arrowWidth / 2;

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

    if (boxShadow != null) {
      for (final shadow in boxShadow!) {
        final shadowPath = path.shift(shadow.offset);
        final shadowPaint = Paint()
          ..color = shadow.color.withValues(alpha: shadow.color.a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurRadius);
        canvas.drawPath(shadowPath, shadowPaint);
      }
    }

    canvas.drawPath(path, fillPaint);
    if (borderWidth > 0.001) {
      canvas.drawPath(path, borderPaint);
    }
  }

  void _paintBelowPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    final Rect bodyRect = Rect.fromLTWH(
      0,
      arrowSize,
      size.width,
      size.height - arrowSize,
    );

    path.moveTo(bodyRect.left + borderRadius.x, bodyRect.top);
    if (arrowOffset - arrowHalfWidth > bodyRect.left + borderRadius.x) {
      path.lineTo(arrowOffset - arrowHalfWidth, bodyRect.top);
      path.lineTo(arrowOffset, bodyRect.top - arrowSize);
      path.lineTo(arrowOffset + arrowHalfWidth, bodyRect.top);
    }
    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.top);

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

  void _paintAbovePath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    final Rect bodyRect = Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height - arrowSize,
    );

    path.moveTo(bodyRect.left + borderRadius.x, bodyRect.bottom);
    if (arrowOffset - arrowHalfWidth > bodyRect.left + borderRadius.x) {
      path.lineTo(arrowOffset - arrowHalfWidth, bodyRect.bottom);
      path.lineTo(arrowOffset, bodyRect.bottom + arrowSize);
      path.lineTo(arrowOffset + arrowHalfWidth, bodyRect.bottom);
    }
    path.lineTo(bodyRect.right - borderRadius.x, bodyRect.bottom);

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

  void _paintLeftPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    final Rect bodyRect = Rect.fromLTWH(
      arrowSize,
      0,
      size.width - arrowSize,
      size.height,
    );

    path.moveTo(bodyRect.left, bodyRect.top + borderRadius.y);
    if (arrowOffset - arrowHalfWidth > bodyRect.top + borderRadius.y) {
      path.lineTo(bodyRect.left, arrowOffset - arrowHalfWidth);
      path.lineTo(bodyRect.left - arrowSize, arrowOffset);
      path.lineTo(bodyRect.left, arrowOffset + arrowHalfWidth);
    }
    path.lineTo(bodyRect.left, bodyRect.bottom - borderRadius.y);

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

  void _paintRightPath(Path path, Size size, double arrowWidth,
      double arrowHalfWidth, double arrowOffset) {
    final Rect bodyRect = Rect.fromLTWH(
      0,
      0,
      size.width - arrowSize,
      size.height,
    );

    path.moveTo(bodyRect.right, bodyRect.top + borderRadius.y);
    if (arrowOffset - arrowHalfWidth > bodyRect.top + borderRadius.y) {
      path.lineTo(bodyRect.right, arrowOffset - arrowHalfWidth);
      path.lineTo(bodyRect.right + arrowSize, arrowOffset);
      path.lineTo(bodyRect.right, arrowOffset + arrowHalfWidth);
    }
    path.lineTo(bodyRect.right, bodyRect.bottom - borderRadius.y);

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
