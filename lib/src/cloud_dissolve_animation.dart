import 'dart:ui';
import 'package:flutter/material.dart';

/// Cloud Dissolve Animation Widget.
///
/// Creates a dreamy cloud-like dissolve effect using Overlay for unbounded animation.
/// The widget is rendered at the top layer of the app, allowing blur to spread freely.
///
/// Animation effects:
/// 1. Blurs progressively with high sigma for cloud-like spreading
/// 2. Floats upward with slight scale expansion
/// 3. Fades out smoothly
/// 4. Original space collapses for smooth list gap closing
///
/// Example:
/// ```dart
/// CloudDissolveAnimation(
///   onComplete: () => setState(() => items.removeAt(index)),
///   child: MyWidget(),
/// )
/// ```
class CloudDissolveAnimation extends StatefulWidget {
  /// The widget to dissolve.
  final Widget child;

  /// Called when the dissolve animation completes.
  final VoidCallback? onComplete;

  /// Duration of the dissolve animation.
  final Duration duration;

  /// Animation curve.
  final Curve curve;

  /// Whether to shrink the widget size during animation.
  ///
  /// Set to `false` when the animation should overflow its bounds
  /// (e.g., in fixed-size containers).
  final bool shrinkSize;

  const CloudDissolveAnimation({
    super.key,
    required this.child,
    this.onComplete,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.shrinkSize = true,
  });

  @override
  State<CloudDissolveAnimation> createState() => _CloudDissolveAnimationState();
}

class _CloudDissolveAnimationState extends State<CloudDissolveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _sizeAnimation;

  OverlayEntry? _overlayEntry;
  final GlobalKey _childKey = GlobalKey();
  Offset? _childPosition;
  Size? _childSize;
  bool _overlayInserted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Blur: 0 -> 30 (high blur for cloud-like spreading effect)
    _blurAnimation = Tween<double>(begin: 0.0, end: 30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Opacity: 1 -> 0 (fade out)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Scale: 1 -> 1.15 (expand outward for spreading effect)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Float upward: 0 -> -30 pixels
    _floatAnimation = Tween<double>(begin: 0.0, end: -30.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Size: 1 -> 0 (shrink height for smooth gap closing)
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // Capture position after first frame and start overlay animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _capturePositionAndStartOverlay();
    });

    // Complete callback
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removeOverlay();
        widget.onComplete?.call();
      }
    });
  }

  void _capturePositionAndStartOverlay() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      _childPosition = renderBox.localToGlobal(Offset.zero);
      _childSize = renderBox.size;
      _insertOverlay();
      _controller.forward();
    } else {
      // Retry if render box not ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _capturePositionAndStartOverlay();
      });
    }
  }

  void _insertOverlay() {
    if (_overlayInserted) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _CloudDissolveOverlay(
        position: _childPosition!,
        size: _childSize!,
        controller: _controller,
        blurAnimation: _blurAnimation,
        opacityAnimation: _opacityAnimation,
        scaleAnimation: _scaleAnimation,
        floatAnimation: _floatAnimation,
        child: KeyedSubtree(
          key: ValueKey('cloud_dissolve_overlay_${identityHashCode(widget)}'),
          child: widget.child,
        ),
      ),
    );

    _overlayInserted = true;
    Overlay.of(context).insert(_overlayEntry!);

    if (mounted) {
      setState(() {});
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    _overlayInserted = false;
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sizeAnimation,
      builder: (context, child) {
        final showPlaceholder = _overlayInserted;

        if (widget.shrinkSize) {
          return SizeTransition(
            sizeFactor: _sizeAnimation,
            axisAlignment: 0.0,
            child: showPlaceholder
                ? SizedBox(
                    width: _childSize?.width ?? 0,
                    height: _childSize?.height ?? 0)
                : KeyedSubtree(key: _childKey, child: widget.child),
          );
        }

        return showPlaceholder
            ? SizedBox(
                width: _childSize?.width ?? 0,
                height: _childSize?.height ?? 0)
            : KeyedSubtree(key: _childKey, child: widget.child);
      },
    );
  }
}

/// Overlay widget that renders the dissolve animation at the top layer.
class _CloudDissolveOverlay extends StatelessWidget {
  final Offset position;
  final Size size;
  final AnimationController controller;
  final Animation<double> blurAnimation;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> floatAnimation;
  final Widget child;

  const _CloudDissolveOverlay({
    required this.position,
    required this.size,
    required this.controller,
    required this.blurAnimation,
    required this.opacityAnimation,
    required this.scaleAnimation,
    required this.floatAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Positioned(
          left: position.dx,
          top: position.dy + floatAnimation.value,
          width: size.width,
          height: size.height,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scaleAnimation.value,
              child: Opacity(
                opacity: opacityAnimation.value,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: blurAnimation.value,
                    sigmaY: blurAnimation.value,
                    tileMode: TileMode.decal,
                  ),
                  child:
                      Material(type: MaterialType.transparency, child: child),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
