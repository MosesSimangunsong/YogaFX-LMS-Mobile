import 'package:flutter/material.dart';

class ShellSkeleton extends StatefulWidget {
  const ShellSkeleton({
    super.key,
    required this.height,
    this.width,
    this.radius = 18,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<ShellSkeleton> createState() => _ShellSkeletonState();
}

class _ShellSkeletonState extends State<ShellSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.4);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Colors.white.withValues(alpha: opacity * 0.14),
          ),
        );
      },
    );
  }
}
