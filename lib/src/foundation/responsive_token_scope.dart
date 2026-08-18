import 'package:flutter/widgets.dart';

import 'desktop_tokens.dart';
import 'token_scope.dart';

/// A [TokenScope] that automatically switches between token sets based on
/// the current window / screen width.
///
/// This implements the "responsive Token" cross-cutting capability: when the
/// window is narrow (e.g. a side-panel), a compact token set is used; when
/// the window is wide, a comfortable / spacious set is applied.
///
/// ```dart
/// ResponsiveTokenScope(
///   compact: DesktopTokens.winForm,
///   comfortable: DesktopTokens.winForm.copyWith(fontSize: 14, controlHeight: 32),
///   spacious: DesktopTokens.winForm.copyWith(fontSize: 16, controlHeight: 40),
///   child: MyApp(),
/// )
/// ```
class ResponsiveTokenScope extends StatelessWidget {
  const ResponsiveTokenScope({
    super.key,
    required this.compact,
    this.comfortable,
    this.spacious,
    this.compactBreakpoint = 600,
    this.spaciousBreakpoint = 1200,
    required this.child,
  });

  /// Tokens used when the width is below [compactBreakpoint].
  final DesktopTokens compact;

  /// Tokens used when the width is between [compactBreakpoint] and
  /// [spaciousBreakpoint]. Falls back to [compact] when `null`.
  final DesktopTokens? comfortable;

  /// Tokens used when the width is >= [spaciousBreakpoint].
  /// Falls back to [comfortable] ?? [compact] when `null`.
  final DesktopTokens? spacious;

  /// Width threshold below which [compact] tokens are used.
  final double compactBreakpoint;

  /// Width threshold above which [spacious] tokens are used.
  final double spaciousBreakpoint;

  /// The widget subtree that receives the resolved tokens.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder reads the incoming width without rebuilding the
    // whole subtree through a synthetic MediaQuery (which would drop
    // any parent MediaQuery customisations such as padding or text
    // scaling).
    return LayoutBuilder(
      builder: (context, constraints) {
        return TokenScope(tokens: _resolve(constraints.maxWidth), child: child);
      },
    );
  }

  DesktopTokens _resolve(double width) {
    if (width >= spaciousBreakpoint && spacious != null) return spacious!;
    if (width >= compactBreakpoint) return comfortable ?? compact;
    return compact;
  }
}
