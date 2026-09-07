import 'package:flutter/material.dart';

class FadeView extends StatelessWidget {
  final Widget? child;
  const FadeView({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 20.0, end: 1.0),
      builder: (context, value, c) {
        return AnimatedOpacity(
          opacity: value == 20 ? 0 : 1,
          duration: const Duration(milliseconds: 700),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
