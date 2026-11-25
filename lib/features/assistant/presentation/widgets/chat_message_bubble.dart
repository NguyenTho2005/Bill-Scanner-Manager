import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Renders one conversation turn with its rich blocks and suggestion chips.
class ChatMessageBubble extends StatelessWidget {
  /// Creates a [ChatMessageBubble].
  const ChatMessageBubble({
    required this.message,
    required this.onSuggestionTap,
    required this.onConfirmDraft,
    required this.onDismissDraft,
    super.key,
  });

  /// Message to render.
  final ChatMessage message;

  /// Called when a follow-up chip is tapped.
  final ValueChanged<String> onSuggestionTap;

  /// Called when the user confirms a draft.
  final void Function(String messageId, TransactionDraft draft) onConfirmDraft;

  /// Called when the user dismisses a draft.
  final void Function(String messageId) onDismissDraft;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(left: 48, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary,
                    Color.alphaBlend(
                      AppColors.bills.withAlpha(150),
                      colors.primary,
                    ),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withAlpha(38),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const Gap(4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isFeedback) ...[
                  Icon(
                    Icons.inbox_outlined,
                    size: 12,
                    color: colors.onSurfaceVariant,
                  ),
                  const Gap(4),
                  Text(
                    'Đã lưu phản hồi',
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Gap(8),
                ],
                Text(
                  message.createdAt.toDisplayTime(),
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AssistantGlyph(size: 30),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withAlpha(100),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withAlpha(90),
                      width: 0.6,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.text,
                        style: textTheme.bodyMedium?.copyWith(height: 1.45),
                      ),
                      for (final block in message.blocks) ...[
                        const Gap(12),
                        _BlockRenderer(
                          block: block,
                          messageId: message.id,
                          onConfirmDraft: onConfirmDraft,
                          onDismissDraft: onDismissDraft,
                        ),
                      ],
                    ],
                  ),
                ),
                if (message.suggestions.isNotEmpty) ...[
                  const Gap(8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: message.suggestions
                        .map(
                          (suggestion) => ActionChip(
                            label: Text(suggestion),
                            visualDensity: VisualDensity.compact,
                            labelStyle: textTheme.labelSmall,
                            onPressed: () => onSuggestionTap(suggestion),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const Gap(4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      message.isLocal
                          ? Icons.lock_outline_rounded
                          : Icons.cloud_outlined,
                      size: 11,
                      color: colors.onSurfaceVariant,
                    ),
                    const Gap(4),
                    Text(
                      message.isLocal
                          ? 'Xử lý trên thiết bị'
                          : 'Trả lời bởi AI cloud',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      message.createdAt.toDisplayTime(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantGlyph extends StatelessWidget {
  const _AssistantGlyph({required this.size});

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
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: size * 0.52,
        color: Colors.white,
      ),
    );
  }
}

class _BlockRenderer extends StatelessWidget {
  const _BlockRenderer({
    required this.block,
    required this.messageId,
    required this.onConfirmDraft,
    required this.onDismissDraft,
  });

  final AssistantBlock block;
  final String messageId;
  final void Function(String messageId, TransactionDraft draft) onConfirmDraft;
  final void Function(String messageId) onDismissDraft;

  @override
  Widget build(BuildContext context) {
    final block = this.block;
    if (block is MetricBlock) return _MetricsTable(block: block);
    if (block is TransactionsBlock) return _TransactionsList(block: block);
    if (block is NoteBlock) return _NoteCallout(block: block);
    if (block is DraftBlock) {
      return _DraftCard(
        block: block,
        onConfirm: () => onConfirmDraft(messageId, block.draft),
        onDismiss: () => onDismissDraft(messageId),
      );
    }
    return const SizedBox.shrink();
  }
}

class _MetricsTable extends StatelessWidget {
  const _MetricsTable({required this.block});

  final MetricBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (block.title != null) ...[
            Text(
              block.title!,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
            const Gap(8),
          ],
          for (var i = 0; i < block.rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 14,
                thickness: 0.5,
                color: colors.outlineVariant,
              ),
            _MetricRowView(row: block.rows[i]),
          ],
        ],
      ),
    );
  }
}

class _MetricRowView extends StatelessWidget {
  const _MetricRowView({required this.row});

  final MetricRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              if (row.hint != null)
                Text(
                  row.hint!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.outline,
                  ),
                ),
            ],
          ),
        ),
        const Gap(8),
        Text(
          row.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList({required this.block});

  final TransactionsBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          for (var i = 0; i < block.items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: colors.outlineVariant,
              ),
            _TransactionRow(item: block.items[i]),
          ],
          if (block.totalAmount != null) ...[
            Divider(height: 0.5, thickness: 0.5, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Tổng',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    block.totalAmount!.toVnd(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});

  final TransactionPreview item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final title = item.merchant ?? item.note ?? item.categoryName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              color: Color(item.categoryColorValue),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.categoryName} · ${item.occurredAt.toDisplayDate()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Text(
            item.amount.toVnd(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCallout extends StatelessWidget {
  const _NoteCallout({required this.block});

  final NoteBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final (background, foreground, icon) = switch (block.tone) {
      NoteTone.warning => (
          colors.errorContainer.withAlpha(140),
          colors.onErrorContainer,
          Icons.warning_amber_rounded,
        ),
      NoteTone.success => (
          AppColors.success.withAlpha(30),
          colors.onSurface,
          Icons.check_circle_outline_rounded,
        ),
      NoteTone.info => (
          colors.secondaryContainer.withAlpha(120),
          colors.onSecondaryContainer,
          Icons.info_outline_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: foreground),
          const Gap(8),
          Expanded(
            child: Text(
              block.text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                height: 1.4,
              ),
            ),
          ),
          if (block.copyable)
            IconButton(
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              tooltip: 'Sao chép',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: block.text));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép')),
                );
              },
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.block,
    required this.onConfirm,
    required this.onDismiss,
  });

  final DraftBlock block;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final draft = block.draft;
    final isIncome = draft.type == TransactionType.income;
    final accent = isIncome ? AppColors.success : colors.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: accent.withAlpha(120), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
                size: 14,
                color: accent,
              ),
              const Gap(6),
              Text(
                isIncome ? 'Khoản thu' : 'Khoản chi',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                draft.occurredAt.toDisplayDate(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            draft.amount.toVnd(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (draft.note != null)
            Text(
              draft.note!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          const Gap(8),
          Row(
            children: [
              Icon(
                Icons.sell_outlined,
                size: 13,
                color: colors.onSurfaceVariant,
              ),
              const Gap(4),
              Text(
                draft.categoryName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Gap(10),
          switch (block.state) {
            DraftState.pending => Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Lưu giao dịch'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const Gap(8),
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('Bỏ'),
                  ),
                ],
              ),
            DraftState.created => Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const Gap(6),
                  Text(
                    'Đã lưu vào sổ giao dịch',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            DraftState.dismissed => Text(
                'Đã bỏ qua',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
          },
        ],
      ),
    );
  }
}
