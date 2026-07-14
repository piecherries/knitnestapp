import 'package:flutter/material.dart';

class FloatingBubble extends StatefulWidget {
  final double size;
  final Color color;
  final double top;
  final double left;
  final Duration duration;

  const FloatingBubble({
    super.key,
    required this.size,
    required this.color,
    required this.top,
    required this.left,
    this.duration = const Duration(seconds: 4), // Default 4 detik
  });

  @override
  State<FloatingBubble> createState() => _FloatingBubbleState();
}

class _FloatingBubbleState extends State<FloatingBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Positioned(
          top: widget.top + _animation.value,
          left: widget.left,
          child: child!,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.28),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}