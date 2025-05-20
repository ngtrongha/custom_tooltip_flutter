import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class CustomTooltip extends StatefulWidget {
  final Widget child;
  final Widget tooltipContent;
  final double arrowSize;
  final double offset;
  final double? contentWidth;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;

  const CustomTooltip({
    super.key,
    required this.child,
    required this.tooltipContent,
    this.arrowSize = 8,
    this.offset = 4.0,
    this.contentWidth,
    this.decoration,
    this.padding,
  });

  static BoxDecoration _defaultDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black87
          : Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _hideTimer;

  bool _isMouseOverTarget = false;
  bool _isMouseOverTooltip = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  void _tryShowTooltip() {
    _hideTimer?.cancel();
    if (_animationController.status == AnimationStatus.reverse) {
      _animationController.forward();
      return;
    }
    if (_overlayEntry == null) {
      final effectiveDecoration =
          widget.decoration ?? CustomTooltip._defaultDecoration(context);
      final bgColor = effectiveDecoration.color ?? Colors.white;
      final br = effectiveDecoration.borderRadius
              ?.resolve(ui.TextDirection.ltr)
              .topLeft ??
          const Radius.circular(8);

      BorderSide borderSide = BorderSide.none;
      if (effectiveDecoration.border is Border) {
        final border = effectiveDecoration.border as Border?;
        if (border != null && border.top != BorderSide.none) {
          borderSide = border.top;
        } else {
          borderSide = BorderSide(color: bgColor, width: 1.0);
        }
      } else {
        borderSide = BorderSide(color: bgColor, width: 1.0);
      }
      final double borderWidth = borderSide.width;

      _overlayEntry = OverlayEntry(
        builder: (context) {
          final EdgeInsetsGeometry baseContentPadding =
              widget.padding ?? const EdgeInsets.all(12.0);
          final EdgeInsets resolvedContentPadding =
              baseContentPadding.resolve(ui.TextDirection.ltr);

          final EdgeInsets finalPadding = EdgeInsets.fromLTRB(
            resolvedContentPadding.left + borderWidth,
            resolvedContentPadding.top + widget.arrowSize + borderWidth,
            resolvedContentPadding.right + borderWidth,
            resolvedContentPadding.bottom + borderWidth,
          );

          return CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: Offset(0, widget.offset),
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.topCenter,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(),
                    child: Material(
                      color: Colors.transparent,
                      child: CustomPaint(
                        painter: CustomTooltipShapePainter(
                          backgroundColor: bgColor,
                          borderColor: borderSide.color,
                          borderWidth: borderWidth,
                          borderRadius: br,
                          arrowSize: widget.arrowSize,
                          boxShadow: effectiveDecoration.boxShadow,
                        ),
                        child: Container(
                          constraints: widget.contentWidth != null
                              ? BoxConstraints(
                                  minWidth: widget.contentWidth!,
                                  maxWidth: widget.contentWidth!,
                                )
                              : null,
                          padding: finalPadding,
                          child: MouseRegion(
                            onEnter: (_) {
                              _isMouseOverTooltip = true;
                              _hideTimer?.cancel();
                            },
                            onExit: (_) {
                              _isMouseOverTooltip = false;
                              _tryHideTooltip();
                            },
                            child: widget.tooltipContent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
      Overlay.of(context).insert(_overlayEntry!);
    }
    _animationController.forward();
  }

  void _tryHideTooltip() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isMouseOverTarget && !_isMouseOverTooltip) {
        if (_animationController.status == AnimationStatus.forward ||
            _animationController.status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isMouseOverTarget = true;
        _tryShowTooltip();
      },
      onExit: (_) {
        _isMouseOverTarget = false;
        _tryHideTooltip();
      },
      child: CompositedTransformTarget(link: _layerLink, child: widget.child),
    );
  }
}

class CustomTooltipShapePainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Radius borderRadius;
  final double arrowSize;
  final List<BoxShadow>? boxShadow;

  CustomTooltipShapePainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.arrowSize,
    this.boxShadow,
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

    final Rect bodyRect = Rect.fromLTWH(
      0,
      arrowSize,
      size.width,
      size.height - arrowSize,
    );

    Path path = Path();
    path.moveTo(bodyRect.left + borderRadius.x, bodyRect.top);

    path.lineTo(bodyRect.center.dx - arrowHalfWidth, bodyRect.top);
    path.lineTo(bodyRect.center.dx, bodyRect.top - arrowSize);
    path.lineTo(bodyRect.center.dx + arrowHalfWidth, bodyRect.top);
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

    if (boxShadow != null) {
      for (final shadow in boxShadow!) {
        canvas.drawPath(path.shift(shadow.offset), shadow.toPaint());
      }
    }

    canvas.drawPath(path, fillPaint);
    if (borderWidth > 0.001) {
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(CustomTooltipShapePainter oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        borderColor != oldDelegate.borderColor ||
        borderWidth != oldDelegate.borderWidth ||
        borderRadius != oldDelegate.borderRadius ||
        arrowSize != oldDelegate.arrowSize ||
        boxShadow != oldDelegate.boxShadow;
  }
}
