import 'dart:math' as math;

import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_chat_panel.dart';
import 'package:flutter/material.dart';

/// Opens the assistant as a floating popup anchored above the bottom bar.
///
/// On phones it behaves like a tall bottom sheet; on wide layouts it becomes a
/// compact chat window docked to the bottom-right corner.
Future<void> showAssistantPopup(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Đóng trợ lý chi tiêu',
    barrierColor: Colors.black.withAlpha(110),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => const _AssistantPopupLayout(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          alignment: Alignment.bottomRight,
          child: child,
        ),
      );
    },
  );
}

class _AssistantPopupLayout extends StatelessWidget {
  const _AssistantPopupLayout();

  static const double _wideWidth = 430;
  static const double _compactMaxHeight = 760;
  static const double _wideMaxHeight = 640;
  static const double _minHeight = 260;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    final insets = media.viewInsets;
    final padding = media.padding;

    final isCompact = size.width < 720;
    final horizontal = isCompact ? 12.0 : 20.0;
    final width = isCompact ? size.width - horizontal * 2 : _wideWidth;
    final topInset = padding.top + (isCompact ? 10 : 12);
    final available = size.height - topInset - insets.bottom - 14;
    final maxHeight = isCompact ? _compactMaxHeight : _wideMaxHeight;
    final height = math.min(maxHeight, math.max(_minHeight, available));

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(
        horizontal,
        topInset,
        horizontal,
        insets.bottom + 14,
      ),
      child: Align(
        alignment: isCompact ? Alignment.bottomCenter : Alignment.bottomRight,
        child: SizedBox(
          width: width,
          height: height,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 24,
            shadowColor: Colors.black.withAlpha(90),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
              side: BorderSide(
                color:
                    Theme.of(context).colorScheme.outlineVariant.withAlpha(150),
                width: 0.6,
              ),
            ),
            child: Semantics(
              namesRoute: true,
              label: 'Trợ lý chi tiêu',
              child: AssistantChatPanel(
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
