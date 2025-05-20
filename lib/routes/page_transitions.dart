import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage extends CustomTransitionPage<void> {
  FadeTransitionPage({required super.child, super.name, super.arguments, super.key})
    : super(
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

class SlideTransitionPage extends CustomTransitionPage<void> {
  SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.key,
    bool fromBottom = false,
  }) : super(
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final begin = fromBottom ? const Offset(0.0, 1.0) : const Offset(1.0, 0.0);
           const end = Offset.zero;
           const curve = Curves.easeInOut;

           final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

           return SlideTransition(position: animation.drive(tween), child: child);
         },
       );
}
