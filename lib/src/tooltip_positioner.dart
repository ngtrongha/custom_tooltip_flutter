import 'package:flutter/material.dart';
import 'preferred_position.dart';
import 'custom_tooltip_shape_painter.dart';

class TooltipPositioner extends StatefulWidget {
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

  const TooltipPositioner({
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
  State<TooltipPositioner> createState() => _TooltipPositionerState();
}

class _TooltipPositionerState extends State<TooltipPositioner> {
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
        if (left < 8) left = 8;
        if (left + tooltipSize.width > widget.screenSize.width - 8) {
          left = widget.screenSize.width - tooltipSize.width - 8;
        }
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
