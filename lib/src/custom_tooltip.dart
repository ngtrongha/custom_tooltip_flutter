import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:custom_tooltip_flutter/src/preferred_position.dart';
import 'package:custom_tooltip_flutter/src/tooltip_positioner.dart';

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

abstract class CustomTooltipState extends State<CustomTooltip> {
  void hideTooltip();
}

class _CustomTooltipState extends State<CustomTooltip>
    with SingleTickerProviderStateMixin
    implements CustomTooltipState {
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

  @override
  void hideTooltip() {
    if (_isTooltipVisible) {
      _tryHideTooltip();
      _isTooltipVisible = false;
    }
  }
}
