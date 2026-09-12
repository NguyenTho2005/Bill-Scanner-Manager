import 'dart:io';

import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/screens/create_edit_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying comprehensive details of a single transaction.
class TransactionDetailScreen extends ConsumerWidget {
  /// Creates [TransactionDetailScreen].
  const TransactionDetailScreen({
    required this.transactionId,
    super.key,
  });

  /// ID of transaction to view.
  final String transactionId;

  String _formatSource(TransactionSource source) {
    switch (source) {
      case TransactionSource.productSnap:
        return 'Chụp sản phẩm (AI)';
      case TransactionSource.receiptScan:
        return 'Quét hóa đơn (OCR)';
      case TransactionSource.manual:
        return 'Nhập thủ công';
      case TransactionSource.import_:
        return 'Nhập từ file';
    }
  }

  String _formatPayment(PaymentMethod? method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.card:
        return 'Thẻ ngân hàng';
      case PaymentMethod.transfer:
        return 'Chuyển khoản';
      case PaymentMethod.ewallet:
        return 'Ví điện tử';
      case PaymentMethod.other:
      case null:
        return 'Khác';
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa giao dịch này? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      final success = await ref
          .read(transactionControllerProvider.notifier)
          .delete(transactionId);
      if (context.mounted) {
        if (success) {
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa giao dịch thất bại')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionDetailProvider(transactionId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết giao dịch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.error,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (tx) {
          if (tx == null) {
            return const Center(child: Text('Không tìm thấy giao dịch'));
          }

          final isExpense = tx.type == TransactionType.expense;
          final cat = tx.category;
          final catColor = cat?.color ?? colorScheme.primary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(8),

                // ── Category Icon Badge ───────────────────────────────
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.category_rounded,
                    color: catColor,
                    size: 32,
                  ),
                ),
                const Gap(12),

                // ── Category & Merchant ───────────────────────────────
                Text(
                  cat?.name ?? 'Chưa phân loại',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tx.merchant != null) ...[
                  const Gap(4),
                  Text(
                    tx.merchant!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],

                const Gap(16),

                // ── Amount ────────────────────────────────────────────
                Text(
                  '${isExpense ? '-' : '+'}${tx.amount.toVnd()}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isExpense ? colorScheme.error : colorScheme.primary,
                  ),
                ),

                const Gap(24),

                // ── Attached Photo Preview ────────────────────────────
                if (tx.thumbnailPath != null &&
                    File(tx.thumbnailPath!).existsSync()) ...[
                  ClipRRect(
                    borderRadius: AppRadius.borderLg,
                    child: Image.file(
                      File(tx.thumbnailPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(16),
                ],

                // ── Metadata Card ─────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Thời gian',
                          value: tx.occurredAt.toDisplayDateTime(),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Phương thức',
                          value: _formatPayment(tx.paymentMethod),
                        ),
                        const Divider(height: 24),
                        _DetailRow(
                          label: 'Nguồn ghi nhận',
                          value: _formatSource(tx.source),
                        ),
                        if (tx.note != null && tx.note!.isNotEmpty) ...[
                          const Divider(height: 24),
                          _DetailRow(
                            label: 'Ghi chú',
                            value: tx.note!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Gap(24),

                // ── Edit Button ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEditTransactionScreen(
                            initialTransaction: tx,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa giao dịch'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
