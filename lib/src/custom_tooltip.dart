import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// A customizable tooltip widget that supports various positions and interactions.
///
/// This widget provides a tooltip that can be positioned above, below, left, or right
/// of the target widget. It supports hover interactions on desktop/web and tap/hold
/// interactions on mobile devices.
class CustomTooltip extends StatefulWidget {
  /// The widget that will trigger the tooltip when interacted with.
  /// This is the widget that users will hover over (desktop/web) or tap/hold (mobile).
  final Widget child;

  /// The content to be displayed inside the tooltip.
  /// This can be any widget, such as Text, Row, Column, or a custom widget.
  final Widget tooltipContent;

  /// The size of the arrow pointing to the target widget.
  /// Default is 8 logical pixels.
  final double arrowSize;

  /// The distance between the tooltip and the target widget.
  /// Default is 4.0 logical pixels.
  final double offset;

  /// The minimum width of the tooltip.
  /// If not specified, the tooltip will size to its content.
  final double? minWidth;

  /// The maximum width of the tooltip.
  /// If not specified, the tooltip will size to its content.
  final double? maxWidth;

  /// Custom decoration for the tooltip.
  /// If not specified, a default decoration with a white/dark background and shadow will be used.
  final BoxDecoration? decoration;

  /// Padding around the tooltip content.
  /// If not specified, a default padding of 12.0 logical pixels on all sides will be used.
  final EdgeInsetsGeometry? padding;

  /// The preferred position of the tooltip relative to the target widget.
  /// The tooltip will try to position itself according to this preference,
  /// but may choose a different position if there isn't enough space.
  /// Default is [PreferredPosition.below].
  final PreferredPosition preferredPosition;

  /// Whether to use hold gesture instead of tap on mobile devices.
  /// When true, the tooltip will show on hold and hide on release.
  /// When false, the tooltip will toggle on tap.
  /// Default is false.
  final bool useHoldGesture;

  /// Creates a custom tooltip widget.
  const CustomTooltip({
    super.key,
    required this.child,
    required this.tooltipContent,
    this.arrowSize = 8,
    this.offset = 4.0,
    this.minWidth,
    this.maxWidth,
    this.decoration,
    this.padding,
    this.preferredPosition = PreferredPosition.below,
    this.useHoldGesture = false,
  });

  /// Creates a default decoration for the tooltip based on the current theme.
  static BoxDecoration _defaultDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? Colors.black87 : Colors.white,
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

/// The preferred position of the tooltip relative to the target widget.
enum PreferredPosition {
  /// Position the tooltip above the target widget.
  above,

  /// Position the tooltip below the target widget.
  below,

  /// Position the tooltip to the left of the target widget.
  left,

  /// Position the tooltip to the right of the target widget.
  right,
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _hideTimer;
  final GlobalKey _tooltipKey = GlobalKey();

  bool _isMouseOverTarget = false;
  final bool _isMouseOverTooltip = false;
  bool _isTooltipVisible = false;
  bool _isHolding = false;

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

    _animationController.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.removeStatusListener(_handleAnimationStatus);
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _tryShowTooltip() {
    _hideTimer?.cancel();
    if (_animationController.status == AnimationStatus.reverse) {
      _animationController.forward();
      return;
    }
    if (_overlayEntry == null) {
      _createOverlayEntry();
    }
    _animationController.forward();
  }

  void _createOverlayEntry() {
    final effectiveDecoration =
        widget.decoration ?? CustomTooltip._defaultDecoration(context);
    final bgColor = effectiveDecoration.color ?? Colors.white;
    final br =
        effectiveDecoration.borderRadius?.resolve(TextDirection.ltr).topLeft ??
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

    final RenderBox targetBox = context.findRenderObject() as RenderBox;
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;
    final screenSize = MediaQuery.of(context).size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          _TooltipPositioner(
            key: _tooltipKey,
            targetPosition: targetPosition,
            targetSize: targetSize,
            screenSize: screenSize,
            offset: widget.offset,
            animation: _opacityAnimation,
            scaleAnimation: _scaleAnimation,
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
            arrowSize: widget.arrowSize,
            borderWidth: borderSide.width,
            padding: widget.padding,
            decoration: effectiveDecoration,
            tooltipContent: widget.tooltipContent,
            borderRadius: br,
            borderColor: borderSide.color,
            boxShadow: effectiveDecoration.boxShadow,
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _tryHideTooltip() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isMouseOverTarget && !_isMouseOverTooltip && !_isHolding) {
        if (_animationController.status == AnimationStatus.forward ||
            _animationController.status == AnimationStatus.completed) {
          _animationController.reverse();
        }
      }
    });
  }

  void _toggleTooltip() {
    if (_isTooltipVisible) {
      _tryHideTooltip();
    } else {
      _tryShowTooltip();
    }
    _isTooltipVisible = !_isTooltipVisible;
  }

  void _handleHoldStart() {
    _isHolding = true;
    _tryShowTooltip();
  }

  void _handleHoldEnd() {
    _isHolding = false;
    _tryHideTooltip();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
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

    return GestureDetector(
      onTap: widget.useHoldGesture ? null : _toggleTooltip,
      onLongPressStart:
          widget.useHoldGesture ? (_) => _handleHoldStart() : null,
      onLongPressEnd: widget.useHoldGesture ? (_) => _handleHoldEnd() : null,
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

class _TooltipPositioner extends StatefulWidget {
  final Offset targetPosition;
  final Size targetSize;
  final Size screenSize;
  final double offset;
  final Animation<double> animation;
  final Animation<double> scaleAnimation;
  final double? minWidth;
  final double? maxWidth;
  final double arrowSize;
  final double borderWidth;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration decoration;
  final Widget tooltipContent;
  final Radius borderRadius;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;

  const _TooltipPositioner({
    super.key,
    required this.targetPosition,
    required this.targetSize,
    required this.screenSize,
    required this.offset,
    required this.animation,
    required this.scaleAnimation,
    required this.minWidth,
    required this.maxWidth,
    required this.arrowSize,
    required this.borderWidth,
    required this.padding,
    required this.decoration,
    required this.tooltipContent,
    required this.borderRadius,
    required this.borderColor,
    required this.boxShadow,
  });

  @override
  State<_TooltipPositioner> createState() => _TooltipPositionerState();
}

class _TooltipPositionerState extends State<_TooltipPositioner> {
  final GlobalKey _childKey = GlobalKey();
  double? _left;
  double? _top;
  double? _arrowOffset;
  PreferredPosition? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  PreferredPosition _chooseBestPosition(Size tooltipSize) {
    final above = widget.targetPosition.dy;
    final below = widget.screenSize.height -
        (widget.targetPosition.dy + widget.targetSize.height);
    final right = widget.screenSize.width -
        (widget.targetPosition.dx + widget.targetSize.width);
    // Ưu tiên dưới, trên, phải, trái
    if (below >= tooltipSize.height + widget.offset) {
      return PreferredPosition.below;
    }
    if (above >= tooltipSize.height + widget.offset) {
      return PreferredPosition.above;
    }
    if (right >= tooltipSize.width + widget.offset) {
      return PreferredPosition.right;
    }
    return PreferredPosition.left;
  }

  void _updatePosition() {
    final RenderBox? tooltipBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (tooltipBox == null) return;
    final tooltipSize = tooltipBox.size;
    final position = _chooseBestPosition(tooltipSize);
    double left = 0, top = 0, arrowOffset = 0;
    const double minArrowPadding = 16;

    switch (position) {
      case PreferredPosition.below:
        left = widget.targetPosition.dx +
            widget.targetSize.width / 2 -
            tooltipSize.width / 2;
        top =
            widget.targetPosition.dy + widget.targetSize.height + widget.offset;
        // Clamp left
        if (left < 8) left = 8;
        if (left + tooltipSize.width > widget.screenSize.width - 8) {
          left = widget.screenSize.width - tooltipSize.width - 8;
        }
        // Arrow offset theo trục X
        arrowOffset =
            (widget.targetPosition.dx + widget.targetSize.width / 2) - left;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.width - minArrowPadding) {
          arrowOffset = tooltipSize.width - minArrowPadding;
        }
        break;
      case PreferredPosition.above:
        left = widget.targetPosition.dx +
            widget.targetSize.width / 2 -
            tooltipSize.width / 2;
        top = widget.targetPosition.dy - tooltipSize.height - widget.offset;
        if (left < 8) left = 8;
        if (left + tooltipSize.width > widget.screenSize.width - 8) {
          left = widget.screenSize.width - tooltipSize.width - 8;
        }
        if (top < 8) top = 8;
        arrowOffset =
            (widget.targetPosition.dx + widget.targetSize.width / 2) - left;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.width - minArrowPadding) {
          arrowOffset = tooltipSize.width - minArrowPadding;
        }
        break;
      case PreferredPosition.right:
        left =
            widget.targetPosition.dx + widget.targetSize.width + widget.offset;
        top = widget.targetPosition.dy +
            widget.targetSize.height / 2 -
            tooltipSize.height / 2;
        if (top < 8) top = 8;
        if (top + tooltipSize.height > widget.screenSize.height - 8) {
          top = widget.screenSize.height - tooltipSize.height - 8;
        }
        // Arrow offset theo trục Y
        arrowOffset =
            (widget.targetPosition.dy + widget.targetSize.height / 2) - top;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.height - minArrowPadding) {
          arrowOffset = tooltipSize.height - minArrowPadding;
        }
        break;
      case PreferredPosition.left:
        left = widget.targetPosition.dx - tooltipSize.width - widget.offset;
        top = widget.targetPosition.dy +
            widget.targetSize.height / 2 -
            tooltipSize.height / 2;
        if (top < 8) top = 8;
        if (top + tooltipSize.height > widget.screenSize.height - 8) {
          top = widget.screenSize.height - tooltipSize.height - 8;
        }
        if (left < 8) left = 8;
        arrowOffset =
            (widget.targetPosition.dy + widget.targetSize.height / 2) - top;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.height - minArrowPadding) {
          arrowOffset = tooltipSize.height - minArrowPadding;
        }
        break;
    }

    setState(() {
      _left = left;
      _top = top;
      _arrowOffset = arrowOffset;
      _position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry baseContentPadding =
        widget.padding ?? const EdgeInsets.all(12.0);
    final EdgeInsets resolvedContentPadding =
        baseContentPadding.resolve(TextDirection.ltr);
    EdgeInsets finalPadding;
    // Điều chỉnh padding theo vị trí
    switch (_position ?? PreferredPosition.below) {
      case PreferredPosition.below:
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
      case PreferredPosition.above:
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.arrowSize + widget.borderWidth,
        );
        break;
      case PreferredPosition.left:
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
      case PreferredPosition.right:
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
    }
    return (_left == null ||
            _top == null ||
            _arrowOffset == null ||
            _position == null)
        ? Positioned(
            left: 0,
            top: 0,
            child: Opacity(
              opacity: 0,
              child: _buildTooltip(finalPadding, 24, PreferredPosition.below),
            ),
          )
        : Positioned(
            left: _left,
            top: _top,
            child: FadeTransition(
              opacity: widget.animation,
              child: ScaleTransition(
                scale: widget.scaleAnimation,
                alignment: Alignment.topCenter,
                child: _buildTooltip(finalPadding, _arrowOffset!, _position!),
              ),
            ),
          );
  }

  Widget _buildTooltip(
      EdgeInsets finalPadding, double arrowOffset, PreferredPosition position) {
    return Material(
      color: Colors.transparent,
      child: Container(
        key: _childKey,
        constraints: BoxConstraints(
          minWidth: widget.minWidth ?? 0,
          maxWidth: widget.maxWidth ?? double.infinity,
        ),
        child: CustomPaint(
          painter: CustomTooltipShapePainter(
            backgroundColor: widget.decoration.color ?? Colors.white,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            arrowSize: widget.arrowSize,
            boxShadow: widget.boxShadow,
            position: position,
            arrowOffset: arrowOffset,
          ),
          child: Container(
            padding: finalPadding,
            child: IntrinsicWidth(
              child: IntrinsicHeight(
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final c = widget.tooltipContent;
    if (c is Align || c is Center || c is Row || c is Column) {
      return c;
    }
    return Center(child: c);
  }
}
