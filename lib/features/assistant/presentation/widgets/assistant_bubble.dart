import 'dart:math' as math;

import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Adds the draggable assistant bubble on top of the shell content.
///
/// The bubble snaps to the nearest side after a drag and shows an unread badge
/// for answers received while the popup was closed.
class AssistantBubbleHost extends ConsumerStatefulWidget {
  /// Creates [AssistantBubbleHost].
  const AssistantBubbleHost({required this.child, super.key});

  /// Screen content rendered underneath the bubble.
  final Widget child;

  @override
  ConsumerState<AssistantBubbleHost> createState() =>
      _AssistantBubbleHostState();
}

class _AssistantBubbleHostState extends ConsumerState<AssistantBubbleHost> {
  static const _size = 58.0;
  static const _edge = 14.0;
  static const _initialBottom = 78.0;

  double? _left;
  double _bottom = _initialBottom;
  bool _dragging = false;

  Offset _dragOrigin = Offset.zero;
  double _dragStartLeft = 0;
  double _dragStartBottom = _initialBottom;

  int? _seenAssistantCount;

  int get _assistantCount {
    final messages = ref.watch(assistantChatProvider).valueOrNull;
    if (messages == null) return 0;
    return messages
        .where((message) => message.role == ChatRole.assistant)
        .length;
  }

  Future<void> _openAssistant() async {
    final count = _assistantCount;
    setState(() => _seenAssistantCount = count);
    await showAssistantPopup(context);
    if (!mounted) return;
    final latest = ref.read(assistantChatProvider).valueOrNull;
    final latestCount = latest == null
        ? count
        : latest.where((message) => message.role == ChatRole.assistant).length;
    setState(() => _seenAssistantCount = latestCount);
  }

  void _onPanStart(DragStartDetails details, double left) {
    _dragOrigin = details.globalPosition;
    _dragStartLeft = left;
    _dragStartBottom = _bottom;
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    BoxConstraints constraints,
  ) {
    final dx = details.globalPosition.dx - _dragOrigin.dx;
    final dy = details.globalPosition.dy - _dragOrigin.dy;
    final maxLeft = math.max(_edge, constraints.maxWidth - _size - _edge);
    final maxBottom = math.max(_edge, constraints.maxHeight - _size - _edge);
    setState(() {
      _dragging = true;
      _left = (_dragStartLeft + dx).clamp(_edge, maxLeft);
      _bottom = (_dragStartBottom - dy).clamp(_edge, maxBottom);
    });
  }

  void _onPanEnd(BoxConstraints constraints) {
    final maxLeft = math.max(_edge, constraints.maxWidth - _size - _edge);
    final current = (_left ?? maxLeft).clamp(_edge, maxLeft);
    setState(() {
      _dragging = false;
      _left = current + _size / 2 < constraints.maxWidth / 2 ? _edge : maxLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    final count = _assistantCount;
    if (_seenAssistantCount == null || _seenAssistantCount! > count) {
      _seenAssistantCount = count;
    }
    final unread = math.max(0, count - _seenAssistantCount!);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxLeft = math.max(_edge, constraints.maxWidth - _size - _edge);
        final maxBottom =
            math.max(_edge, constraints.maxHeight - _size - _edge);
        final left = (_left ?? (constraints.maxWidth - _size - _edge))
            .clamp(_edge, maxLeft);
        final bottom = _bottom.clamp(_edge, maxBottom);

        return Stack(
          children: [
            Positioned.fill(child: widget.child),
            AnimatedPositioned(
              duration:
                  _dragging ? Duration.zero : const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              left: left,
              bottom: bottom,
              width: _size,
              height: _size,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openAssistant,
                onPanStart: (details) => _onPanStart(details, left),
                onPanUpdate: (details) => _onPanUpdate(details, constraints),
                onPanEnd: (_) => _onPanEnd(constraints),
                onPanCancel: () => _onPanEnd(constraints),
                child: Tooltip(
                  message: 'Trợ lý chi tiêu',
                  child: _BubbleBody(
                    unread: unread,
                    active: _dragging,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.unread, required this.active});

  final int unread;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: AnimatedScale(
        scale: active ? 1.08 : 1,
        duration: const Duration(milliseconds: 140),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.onSurface,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: colors.surface,
                size: 26,
              ),
            ),
            // Small chat tail so it reads as a conversation bubble.
            Positioned(
              right: 1,
              bottom: 2,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                top: -4,
                right: -4,
                child: _UnreadBadge(count: unread),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Container(
        key: ValueKey<int>(count),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.surface, width: 1.6),
        ),
        child: Center(
          child: Text(
            count > 9 ? '9+' : '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper used by the assistant entry point in Settings.
class AssistantEntryTile extends StatelessWidget {
  const AssistantEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.onSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: colors.surface,
          size: 20,
        ),
      ),
      title: const Text('Mở trợ lý chi tiêu'),
      subtitle: const Text('Hỏi về chi tiêu hoặc ghi nhanh "cà phê 45k"'),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: () => showAssistantPopup(context),
    );
  }
}
