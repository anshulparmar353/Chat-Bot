import 'package:flutter/material.dart';

class DotAnimation extends StatefulWidget {
  final int delay;

  const DotAnimation({super.key, this.delay = 0});

  @override
  State<DotAnimation> createState() => _DotState();
}

class _DotState extends State<DotAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0,
      end: -8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(Duration(milliseconds: widget.delay));

    if (!mounted || _disposed) return;

    while (mounted && !_disposed) {
      try {
        await _controller.forward();

        if (!mounted || _disposed) return;

        await _controller.reverse();

        if (!mounted || _disposed) return;
      } catch (_) {
        return;
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;

    _controller.stop();

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
