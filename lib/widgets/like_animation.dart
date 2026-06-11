import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LikeAnimation extends HookWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;
  final bool smallLike;

  const LikeAnimation({
    super.key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.smallLike = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: Duration(
        milliseconds: duration.inMilliseconds ~/ 2,
      ),
    );

    final scale = useMemoized(
      () => Tween<double>(begin: 1.0, end: 1.2).animate(controller),
      [controller],
    );

    useEffect(() {
      if (isAnimating || smallLike) {
        Future<void> run() async {
          await controller.forward();
          await controller.reverse();
          await Future.delayed(const Duration(milliseconds: 200));
          if (onEnd != null) {
            onEnd!();
          }
        }
        run();
      }
      return null;
    }, [isAnimating]);

    return ScaleTransition(
      scale: scale,
      child: child,
    );
  }
}
