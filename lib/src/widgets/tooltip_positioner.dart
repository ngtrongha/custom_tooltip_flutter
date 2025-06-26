import 'package:flutter/material.dart';
import '../models/preferred_position.dart';
import '../painters/custom_tooltip_shape_painter.dart';

/// Widget responsible for positioning and rendering the tooltip overlay.
/// This widget handles the dynamic positioning of tooltips based on available screen space
/// and manages mouse interactions for the tooltip content.
class TooltipPositioner extends StatefulWidget {
  /// Position of the target widget in global coordinates
  final Offset targetPosition;

  /// Size of the target widget
  final Size targetSize;

  /// Size of the screen for boundary calculations
  final Size screenSize;

  /// Distance between target and tooltip
  final double offset;

  /// Animation for fade in/out effect
  final Animation<double> animation;

  /// Animation for scale effect
  final Animation<double> scaleAnimation;

  /// Minimum width constraint for tooltip
  final double? minWidth;

  /// Maximum width constraint for tooltip
  final double? maxWidth;

  /// Size of the arrow pointing to target
  final double arrowSize;

  /// Width of the tooltip border
  final double borderWidth;

  /// Padding around tooltip content
  final EdgeInsetsGeometry? padding;

  /// Decoration for the tooltip container
  final BoxDecoration decoration;

  /// Content widget to display in the tooltip
  final Widget tooltipContent;

  /// Border radius for tooltip corners
  final Radius borderRadius;

  /// Color of the tooltip border
  final Color borderColor;

  /// Optional box shadows for the tooltip
  final List<BoxShadow>? boxShadow;

  /// Callback when mouse enters tooltip area (null when tap mode is enabled)
  final VoidCallback? onMouseEnter;

  /// Callback when mouse exits tooltip area (null when tap mode is enabled)
  final VoidCallback? onMouseExit;

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
    this.onMouseEnter,
    this.onMouseExit,
  });

  @override
  State<TooltipPositioner> createState() => _TooltipPositionerState();
}

/// State class for _TooltipPositioner that handles dynamic positioning calculations.
class _TooltipPositionerState extends State<TooltipPositioner> {
  /// Global key for accessing the tooltip widget's render object
  final GlobalKey _childKey = GlobalKey();

  /// Calculated left position for the tooltip
  double? _left;

  /// Calculated top position for the tooltip
  double? _top;

  /// Calculated arrow offset for proper arrow positioning
  double? _arrowOffset;

  /// Determined position of the tooltip relative to target
  PreferredPosition? _position;

  @override
  void initState() {
    super.initState();
    // Calculate position after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  /// Chooses the best position for the tooltip based on available screen space.
  /// Prioritizes: below > above > right > left
  PreferredPosition _chooseBestPosition(Size tooltipSize) {
    // Calculate available space in each direction
    final above = widget.targetPosition.dy;
    final below = widget.screenSize.height -
        (widget.targetPosition.dy + widget.targetSize.height);
    final right = widget.screenSize.width -
        (widget.targetPosition.dx + widget.targetSize.width);

    // Check if there's enough space below the target
    if (below >= tooltipSize.height + widget.offset) {
      return PreferredPosition.below;
    }

    // Check if there's enough space above the target
    if (above >= tooltipSize.height + widget.offset) {
      return PreferredPosition.above;
    }

    // Check if there's enough space to the right of the target
    if (right >= tooltipSize.width + widget.offset) {
      return PreferredPosition.right;
    }

    // Default to left position
    return PreferredPosition.left;
  }

  /// Updates the tooltip position based on the chosen position and screen boundaries.
  void _updatePosition() {
    // Get the tooltip's render object to determine its size
    final RenderBox? tooltipBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (tooltipBox == null) return;

    final tooltipSize = tooltipBox.size;
    final position = _chooseBestPosition(tooltipSize);
    double left = 0, top = 0, arrowOffset = 0;
    const double minArrowPadding = 16; // Minimum padding for arrow from edges

    // Calculate position and arrow offset based on chosen position
    switch (position) {
      case PreferredPosition.below:
        // Position tooltip below target, centered horizontally
        left = widget.targetPosition.dx +
            widget.targetSize.width / 2 -
            tooltipSize.width / 2;
        top =
            widget.targetPosition.dy + widget.targetSize.height + widget.offset;

        // Ensure tooltip stays within screen bounds
        if (left < 8) left = 8;
        if (left + tooltipSize.width > widget.screenSize.width - 8) {
          left = widget.screenSize.width - tooltipSize.width - 8;
        }

        // Calculate arrow offset to point to target center
        arrowOffset =
            (widget.targetPosition.dx + widget.targetSize.width / 2) - left;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.width - minArrowPadding) {
          arrowOffset = tooltipSize.width - minArrowPadding;
        }
        break;

      case PreferredPosition.above:
        // Position tooltip above target, centered horizontally
        left = widget.targetPosition.dx +
            widget.targetSize.width / 2 -
            tooltipSize.width / 2;
        top = widget.targetPosition.dy - tooltipSize.height - widget.offset;

        // Ensure tooltip stays within screen bounds
        if (left < 8) left = 8;
        if (left + tooltipSize.width > widget.screenSize.width - 8) {
          left = widget.screenSize.width - tooltipSize.width - 8;
        }
        if (top < 8) top = 8;

        // Calculate arrow offset
        arrowOffset =
            (widget.targetPosition.dx + widget.targetSize.width / 2) - left;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.width - minArrowPadding) {
          arrowOffset = tooltipSize.width - minArrowPadding;
        }
        break;

      case PreferredPosition.right:
        // Position tooltip to the right of target, centered vertically
        left =
            widget.targetPosition.dx + widget.targetSize.width + widget.offset;
        top = widget.targetPosition.dy +
            widget.targetSize.height / 2 -
            tooltipSize.height / 2;

        // Ensure tooltip stays within screen bounds
        if (top < 8) top = 8;
        if (top + tooltipSize.height > widget.screenSize.height - 8) {
          top = widget.screenSize.height - tooltipSize.height - 8;
        }

        // Calculate arrow offset (vertical for left/right positions)
        arrowOffset =
            (widget.targetPosition.dy + widget.targetSize.height / 2) - top;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.height - minArrowPadding) {
          arrowOffset = tooltipSize.height - minArrowPadding;
        }
        break;

      case PreferredPosition.left:
        // Position tooltip to the left of target, centered vertically
        left = widget.targetPosition.dx - tooltipSize.width - widget.offset;
        top = widget.targetPosition.dy +
            widget.targetSize.height / 2 -
            tooltipSize.height / 2;

        // Ensure tooltip stays within screen bounds
        if (top < 8) top = 8;
        if (top + tooltipSize.height > widget.screenSize.height - 8) {
          top = widget.screenSize.height - tooltipSize.height - 8;
        }
        if (left < 8) left = 8;

        // Calculate arrow offset (vertical for left/right positions)
        arrowOffset =
            (widget.targetPosition.dy + widget.targetSize.height / 2) - top;
        if (arrowOffset < minArrowPadding) arrowOffset = minArrowPadding;
        if (arrowOffset > tooltipSize.height - minArrowPadding) {
          arrowOffset = tooltipSize.height - minArrowPadding;
        }
        break;
    }

    // Update state with calculated positions
    setState(() {
      _left = left;
      _top = top;
      _arrowOffset = arrowOffset;
      _position = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate base padding for tooltip content
    final EdgeInsetsGeometry baseContentPadding =
        widget.padding ?? const EdgeInsets.all(12.0);
    final EdgeInsets resolvedContentPadding =
        baseContentPadding.resolve(TextDirection.ltr);
    EdgeInsets finalPadding;

    // Adjust padding based on tooltip position to account for arrow space
    switch (_position ?? PreferredPosition.below) {
      case PreferredPosition.below:
        // Add arrow space to top padding
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
      case PreferredPosition.above:
        // Add arrow space to bottom padding
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.arrowSize + widget.borderWidth,
        );
        break;
      case PreferredPosition.left:
        // Add arrow space to right padding
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
      case PreferredPosition.right:
        // Add arrow space to left padding
        finalPadding = EdgeInsets.fromLTRB(
          resolvedContentPadding.left + widget.borderWidth,
          resolvedContentPadding.top + widget.borderWidth,
          resolvedContentPadding.right + widget.arrowSize + widget.borderWidth,
          resolvedContentPadding.bottom + widget.borderWidth,
        );
        break;
    }

    // Show invisible placeholder while calculating position, then show actual tooltip
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

  /// Builds the complete tooltip widget with custom painting and mouse interaction.
  Widget _buildTooltip(
      EdgeInsets finalPadding, double arrowOffset, PreferredPosition position) {
    // Create the base tooltip widget
    Widget tooltipWidget = Material(
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

    // Only add MouseRegion if mouse callbacks are provided (not in tap mode)
    if (widget.onMouseEnter != null || widget.onMouseExit != null) {
      tooltipWidget = MouseRegion(
        onEnter: (_) => widget.onMouseEnter?.call(),
        onExit: (_) => widget.onMouseExit?.call(),
        child: tooltipWidget,
      );
    }

    return tooltipWidget;
  }

  /// Builds the content widget with appropriate centering.
  Widget _buildContent() {
    final c = widget.tooltipContent;
    // If content is already a layout widget, use it as is
    if (c is Align || c is Center || c is Row || c is Column) {
      return c;
    }
    // Otherwise, center the content
    return Center(child: c);
  }
}
