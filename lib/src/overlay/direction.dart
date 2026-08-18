import 'package:flutter/material.dart';

/// Explicitly sets the text direction for a subtree — the counterpart of the
/// shadcn "Direction" utility. Useful for RTL islands inside an LTR app.
class Direction extends StatelessWidget {
  const Direction({
    super.key,
    required this.textDirection,
    required this.child,
  });

  /// The direction to apply to [child].
  final TextDirection textDirection;

  final Widget child;

  /// Returns the effective text direction for the given context, or `null`
  /// when no [Directionality] ancestor exists.
  static TextDirection? maybeOf(BuildContext context) =>
      Directionality.maybeOf(context);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: textDirection, child: child);
  }
}
