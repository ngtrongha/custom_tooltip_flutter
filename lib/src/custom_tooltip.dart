import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'models/preferred_position.dart';
import 'widgets/tooltip_positioner.dart';

/// A highly customizable tooltip widget that supports various positions and interactions.
///
/// This widget provides a tooltip that can be positioned above, below, left, or right
/// of the target widget. It supports hover interactions on desktop/web and tap/hold
/// interactions on mobile devices.
///
/// Example:
/// ```dart
/// CustomTooltip(
///   tooltipContent: const Text('This is a tooltip!'),
///   child: const Icon(Icons.info),
/// )
/// ```
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

  /// Whether to enable tap to open tooltip on all platforms.
  /// When true, the tooltip will show on tap and hide on tap again.
  /// When enabled, mouse hover functionality will be disabled.
  /// Default is false.
  final bool enableTapToOpen;

  /// Dùng để truy cập các hàm điều khiển tooltip từ bên ngoài.
  static CustomTooltipState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<_CustomTooltipState>();
    return state;
  }

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
    this.enableTapToOpen = false,
  });

  /// Creates a default decoration for the tooltip based on the current theme.
  /// This method provides a consistent look across light and dark themes.
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

abstract class CustomTooltipState extends State<CustomTooltip> {
  void hideTooltip();
  void showTooltip(); // Thêm hàm public showTooltip
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin
    implements CustomTooltipState {
  OverlayEntry? _overlayEntry;

  /// Layer link for positioning the tooltip relative to the target widget
  final LayerLink _layerLink = LayerLink();

  /// Animation controller for smooth show/hide transitions
  late final AnimationController _animationController;

  /// Opacity animation for fade in/out effect
  late final Animation<double> _opacityAnimation;

  /// Scale animation for zoom in/out effect
  late final Animation<double> _scaleAnimation;

  /// Timer for delayed hiding of tooltip
  Timer? _hideTimer;

  /// Global key for accessing tooltip widget properties
  final GlobalKey _tooltipKey = GlobalKey();

  /// Tracks whether mouse is currently over the target widget
  bool _isMouseOverTarget = false;

  /// Tracks whether mouse is currently over the tooltip content
  bool _isMouseOverTooltip = false;

  /// Tracks the current visibility state of the tooltip
  bool _isTooltipVisible = false;

  /// Tracks whether user is currently holding (for mobile hold gesture)
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with 200ms duration for smooth transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Create opacity animation with ease-in curve for natural fade effect
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInCubic,
    );

    // Create scale animation with ease-out-back curve for bouncy effect
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Listen for animation status changes to clean up overlay when dismissed
    _animationController.addStatusListener(_handleAnimationStatus);
  }

  /// Handles animation status changes to clean up overlay when animation completes
  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      // Remove overlay entry when animation is dismissed
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isTooltipVisible = false;
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.removeStatusListener(_handleAnimationStatus);
    _animationController.stop(); // Dừng animation nếu đang chạy
    _animationController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null; // Đảm bảo overlay được giải phóng
    super.dispose();
  }

  /// Attempts to show the tooltip with smooth animation
  void _tryShowTooltip() {
    // Cancel any pending hide timer
    _hideTimer?.cancel();

    // If animation is currently reversing, forward it to show tooltip
    if (_animationController.status == AnimationStatus.reverse) {
      _animationController.forward();
      _isTooltipVisible = true;
      return;
    }

    // Create overlay entry if it doesn't exist
    if (_overlayEntry == null) {
      _createOverlayEntry();
    }

    // Start the show animation
    _animationController.forward();
    _isTooltipVisible = true;
  }

  /// Creates the overlay entry that contains the tooltip widget
  void _createOverlayEntry() {
    // Get effective decoration (custom or default)
    final effectiveDecoration =
        widget.decoration ?? CustomTooltip._defaultDecoration(context);
    final bgColor = effectiveDecoration.color ?? Colors.white;
    final br =
        effectiveDecoration.borderRadius?.resolve(TextDirection.ltr).topLeft ??
            const Radius.circular(8);

    // Extract border information for arrow styling
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

    // Get target widget position and size for tooltip positioning
    final RenderBox targetBox = context.findRenderObject() as RenderBox;
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final targetSize = targetBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Create overlay entry with tooltip widget
    _overlayEntry = OverlayEntry(
      builder: (context) => TooltipPositioner(
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
        // Mouse callbacks are only active when tap mode is disabled
        onMouseEnter: widget.enableTapToOpen
            ? null
            : () {
                _isMouseOverTooltip = true;
                _hideTimer?.cancel();
              },
        onMouseExit: widget.enableTapToOpen
            ? null
            : () {
                _isMouseOverTooltip = false;
                _tryHideTooltip();
              },
      ),
    );

    // Insert the overlay entry into the overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Attempts to hide the tooltip with a delay to allow for mouse movement
  void _tryHideTooltip() {
    // Cancel any existing hide timer
    _hideTimer?.cancel();

    // Set a timer to hide tooltip after 150ms delay
    _hideTimer = Timer(const Duration(milliseconds: 150), () {
      // In tap mode, only check for holding state
      if (widget.enableTapToOpen) {
        if (!_isHolding) {
          if (_animationController.status == AnimationStatus.forward ||
              _animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          }
        }
      } else {
        // Original logic for mouse hover mode
        // Only hide if mouse is not over target, tooltip, and not holding
        if (!_isMouseOverTarget && !_isMouseOverTooltip && !_isHolding) {
          if (_animationController.status == AnimationStatus.forward ||
              _animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          }
        }
      }
    });
  }

  /// Toggles the tooltip visibility (used for tap interactions)
  void _toggleTooltip() {
    if (_isTooltipVisible) {
      _tryHideTooltip();
    } else {
      _tryShowTooltip();
    }
  }

  /// Handles the start of hold gesture (for mobile hold interaction)
  void _handleHoldStart() {
    _isHolding = true;
    _tryShowTooltip();
  }

  /// Handles the end of hold gesture (for mobile hold interaction)
  void _handleHoldEnd() {
    _isHolding = false;
    _tryHideTooltip();
  }

  @override
  Widget build(BuildContext context) {
    // If tap to open is enabled, use tap gesture for all platforms
    // This mode disables mouse hover functionality
    if (widget.enableTapToOpen) {
      return GestureDetector(
        onTap: _toggleTooltip,
        child: CompositedTransformTarget(link: _layerLink, child: widget.child),
      );
    }

    // Original logic for mouse hover and mobile gestures
    if (kIsWeb) {
      // Web/Desktop: Use mouse hover interactions
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

    // Mobile: Use tap or hold gestures based on useHoldGesture setting
    return GestureDetector(
      onTap: widget.useHoldGesture ? null : _toggleTooltip,
      onLongPressStart:
          widget.useHoldGesture ? (_) => _handleHoldStart() : null,
      onLongPressEnd: widget.useHoldGesture ? (_) => _handleHoldEnd() : null,
      child: CompositedTransformTarget(link: _layerLink, child: widget.child),
    );
  }

  @override
  void hideTooltip() {
    if (_isTooltipVisible) {
      _tryHideTooltip();
    }
  }

  @override
  void showTooltip() {
    if (!_isTooltipVisible) {
      _tryShowTooltip();
    }
  }
}
