import 'dart:math' as math;

import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:bill_tracker/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/assistant_settings_sheet.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/chat_input_bar.dart';
import 'package:bill_tracker/features/assistant/presentation/widgets/chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Conversational assistant panel: spending Q&A, quick capture and support.
///
/// Rendered inside the floating popup, and reused by the full-screen route.
class AssistantChatPanel extends ConsumerWidget {
  /// Creates [AssistantChatPanel].
  const AssistantChatPanel({this.onClose, super.key});

  /// When provided, a close button is shown in the header.
  final VoidCallback? onClose;

  Future<void> _send(WidgetRef ref, String text) async {
    await ref.read(assistantChatProvider.notifier).send(text);
  }

  Future<void> _confirmDraft(
    BuildContext context,
    WidgetRef ref,
    String messageId,
    TransactionDraft draft,
  ) async {
    final ok = await ref
        .read(assistantChatProvider.notifier)
        .confirmDraft(messageId, draft);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không lưu được giao dịch. Vui lòng thử lại.'),
        ),
      );
    }
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá hội thoại?'),
        content: const Text(
          'Toàn bộ tin nhắn trợ lý sẽ bị xoá khỏi thiết bị. '
          'Giao dịch và ngân sách của bạn không bị ảnh hưởng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(assistantChatProvider.notifier).clear();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatAsync = ref.watch(assistantChatProvider);
    final thinking = ref.watch(assistantThinkingProvider);
    final settings = ref.watch(assistantSettingsProvider).valueOrNull;
    final cloudEnabled = settings?.cloudEnabled ?? false;

    return Column(
      children: [
        _PanelHeader(
          cloudEnabled: cloudEnabled,
          onClose: onClose,
          onSettings: () => AssistantSettingsSheet.show(context),
          onClear: () => _confirmClear(context, ref),
        ),
        Expanded(
          child: chatAsync.when(
            loading: _PanelLoading.new,
            error: (error, _) => _PanelError(
              message: '$error',
              onRetry: () => ref.invalidate(assistantChatProvider),
            ),
            data: (messages) {
              final showEmpty = messages.isEmpty && !thinking;
              return Column(
                children: [
                  Expanded(
                    child: showEmpty
                        ? _EmptyState(
                            onPromptTap: (prompt) => _send(ref, prompt),
                          )
                        : ListView.builder(
                            reverse: true,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
                            itemCount: messages.length + (thinking ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (thinking && index == 0) {
                                return const _ThinkingIndicator();
                              }
                              final messageIndex = messages.length -
                                  1 -
                                  (thinking ? index - 1 : index);
                              final message = messages[messageIndex];
                              return ChatMessageBubble(
                                message: message,
                                onSuggestionTap: (prompt) => _send(ref, prompt),
                                onConfirmDraft: (messageId, draft) =>
                                    _confirmDraft(
                                  context,
                                  ref,
                                  messageId,
                                  draft,
                                ),
                                onDismissDraft: (messageId) async {
                                  await ref
                                      .read(assistantChatProvider.notifier)
                                      .dismissDraft(messageId);
                                },
                              );
                            },
                          ),
                  ),
                  ChatInputBar(
                    enabled: !thinking,
                    onSend: (text) => _send(ref, text),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({
    required this.cloudEnabled,
    required this.onSettings,
    required this.onClear,
    this.onClose,
  });

  final bool cloudEnabled;
  final VoidCallback onSettings;
  final VoidCallback onClear;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withAlpha(isDark ? 90 : 165),
            colors.surface,
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant.withAlpha(120),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          const _AssistantAvatar(size: 40),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Trợ lý chi tiêu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const Gap(3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            cloudEnabled ? AppColors.bills : AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(5),
                    Flexible(
                      child: Text(
                        cloudEnabled
                            ? 'AI cloud đang bật'
                            : 'Chạy hoàn toàn trên thiết bị',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cấu hình trợ lý',
            visualDensity: VisualDensity.compact,
            onPressed: onSettings,
            icon: const Icon(Icons.tune_rounded, size: 20),
          ),
          PopupMenuButton<String>(
            tooltip: 'Tuỳ chọn khác',
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            onSelected: (value) {
              if (value == 'clear') onClear();
              if (value == 'settings') onSettings();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.tune_rounded),
                  title: Text('Cấu hình trợ lý'),
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Xoá hội thoại'),
                ),
              ),
            ],
          ),
          if (onClose != null)
            IconButton(
              tooltip: 'Đóng trợ lý',
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

/// Round gradient avatar shared by the bubble, header and empty state.
class _AssistantAvatar extends StatelessWidget {
  const _AssistantAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, AppColors.bills],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withAlpha(60),
            blurRadius: size / 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onPromptTap});

  final ValueChanged<String> onPromptTap;

  static const _promptIcons = <IconData>[
    Icons.summarize_outlined,
    Icons.local_fire_department_outlined,
    Icons.donut_small_outlined,
    Icons.savings_outlined,
    Icons.add_card_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primaryContainer.withAlpha(isDark ? 80 : 150),
                  colors.surfaceContainerHighest.withAlpha(isDark ? 70 : 90),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.primary.withAlpha(35)),
            ),
            child: Row(
              children: [
                const _AssistantAvatar(size: 46),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hỏi nhanh về chi tiêu của bạn',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        'Mình đọc dữ liệu ngay trên máy. Không cần mạng, '
                        'không gửi ảnh hóa đơn đi đâu.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(18),
          Text(
            'GỢI Ý CHO BẠN',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const Gap(8),
          for (var i = 0; i < assistantStarterPrompts.length; i++) ...[
            _PromptTile(
              text: assistantStarterPrompts[i],
              icon: _promptIcons[i % _promptIcons.length],
              onTap: () => onPromptTap(assistantStarterPrompts[i]),
            ),
            if (i < assistantStarterPrompts.length - 1) const Gap(8),
          ],
          const Gap(16),
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color: colors.onSurfaceVariant,
              ),
              const Gap(6),
              Expanded(
                child: Text(
                  'Lịch sử chat lưu cục bộ trong SQLite và xoá được bất cứ lúc nào.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromptTile extends StatelessWidget {
  const _PromptTile({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withAlpha(70),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant.withAlpha(140)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colors.primary.withAlpha(24),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: colors.primary),
              ),
              const Gap(10),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 15,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading / error / typing ────────────────────────────────────────────────

class _PanelLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}

class _PanelError extends StatelessWidget {
  const _PanelError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 36),
            const Gap(10),
            Text(
              'Không tải được hội thoại: $message',
              textAlign: TextAlign.center,
            ),
            const Gap(12),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantAvatar(size: 28),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withAlpha(110),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _TypingDots(),
                const Gap(8),
                Text(
                  'Đang phân tích trên thiết bị…',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value * 3 - index).clamp(0.0, 1.0);
            final opacity = 0.3 + 0.7 * math.sin(phase * math.pi);
            return Padding(
              padding: EdgeInsets.only(right: index == 2 ? 0 : 3),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color.withAlpha((opacity * 255).round()),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
