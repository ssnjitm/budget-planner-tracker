import 'package:flutter/material.dart';

class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({
    required this.child,
    this.baseColor,
    this.highlightColor,
    super.key,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF475569) : const Color(0xFFF3F4F6));
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.1, 0.3, 0.4],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            transform: _SlidingGradientTransform(_controller.value),
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    this.width,
    this.height = 16,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({this.size = 40, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerTextLine extends StatelessWidget {
  const ShimmerTextLine({this.width, this.height = 14, super.key});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: width, height: height, borderRadius: 6);
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({this.height = 88, super.key});

  final double height;

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(height: height, borderRadius: 22);
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({this.count = 5, this.itemHeight = 72, super.key});

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < count; index++) ...[
          ShimmerCard(height: itemHeight),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
