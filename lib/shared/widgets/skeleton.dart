import 'package:flutter/material.dart';

/// Sweeps a soft highlight across placeholder blocks while content loads.
///
/// Wrap a whole skeleton layout once; every grey block inside shimmers in
/// step. When the system asks for reduced motion the highlight is not drawn
/// and the placeholders stay still.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.child,
    this.semanticLabel = 'Loading',
  });

  final Widget child;
  final String semanticLabel;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Semantics(
      label: widget.semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: reduce
            ? widget.child
            : AnimatedBuilder(
                animation: _controller,
                child: widget.child,
                builder: (context, child) {
                  return ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) {
                      final slide = _controller.value * 2.4 - 0.8;
                      return LinearGradient(
                        begin: Alignment(-1 + slide, -0.3),
                        end: Alignment(slide, 0.3),
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x66FFFFFF),
                          Color(0x00FFFFFF),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: child,
                  );
                },
              ),
      ),
    );
  }
}

/// A rounded grey placeholder. Use inside [SkeletonShimmer].
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 16,
    this.color = const Color(0xFFE4EAF2),
  });

  final double height;
  final double? width;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
