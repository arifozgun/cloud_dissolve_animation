import 'package:flutter/material.dart';

import 'cloud_dissolve_animation.dart';

/// A wrapper widget that manages the deletion state and animation.
///
/// Use this in lists to wrap items that can be deleted with a dissolve effect.
///
/// Example:
/// ```dart
/// DeletableItemWrapper(
///   isDeleting: item.isDeleting,
///   onDeleteComplete: () => setState(() => items.remove(item)),
///   child: ListTile(title: Text(item.title)),
/// )
/// ```
class DeletableItemWrapper extends StatefulWidget {
  /// The widget to wrap.
  final Widget child;

  /// Whether the item is currently being deleted.
  ///
  /// Set this to `true` to trigger the dissolve animation.
  final bool isDeleting;

  /// Called when the dissolve animation completes.
  final VoidCallback? onDeleteComplete;

  const DeletableItemWrapper({
    super.key,
    required this.child,
    this.isDeleting = false,
    this.onDeleteComplete,
  });

  @override
  State<DeletableItemWrapper> createState() => _DeletableItemWrapperState();
}

class _DeletableItemWrapperState extends State<DeletableItemWrapper> {
  bool _showDissolveAnimation = false;
  bool _animationComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDeleting) {
      _showDissolveAnimation = true;
    }
  }

  @override
  void didUpdateWidget(DeletableItemWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDeleting && !oldWidget.isDeleting) {
      setState(() {
        _showDissolveAnimation = true;
        _animationComplete = false;
      });
    } else if (!widget.isDeleting && oldWidget.isDeleting) {
      setState(() {
        _showDissolveAnimation = false;
        _animationComplete = false;
      });
    }
  }

  void _onAnimationComplete() {
    setState(() {
      _animationComplete = true;
    });
    widget.onDeleteComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    // If animation has completed, return empty box to prevent blink during rebuild
    if (_animationComplete) {
      return const SizedBox.shrink();
    }

    if (_showDissolveAnimation) {
      return CloudDissolveAnimation(
        onComplete: _onAnimationComplete,
        child: widget.child,
      );
    }
    return widget.child;
  }
}
