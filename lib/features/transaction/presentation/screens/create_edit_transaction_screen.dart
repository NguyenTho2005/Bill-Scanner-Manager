import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bill_tracker/features/transaction/domain/services/duplicate_detector.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/category_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/amount_numpad.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Screen for creating a new transaction or editing an existing one.
class CreateEditTransactionScreen extends ConsumerStatefulWidget {
  /// Creates [CreateEditTransactionScreen].
  const CreateEditTransactionScreen({
    super.key,
    this.initialTransaction,
    this.initialAmount,
    this.initialCategoryId,
    this.initialMerchant,
    this.initialSource = TransactionSource.manual,
  });

  /// Transaction to edit (null if creating).
  final Transaction? initialTransaction;

  /// Optional initial amount (e.g. from OCR or Product Snap).
  final double? initialAmount;

  /// Optional initial category ID.
  final String? initialCategoryId;

  /// Optional initial merchant name.
  final String? initialMerchant;

  /// Source of creation.
  final TransactionSource initialSource;

  @override
  ConsumerState<CreateEditTransactionScreen> createState() =>
      _CreateEditTransactionScreenState();
}

class _CreateEditTransactionScreenState
    extends ConsumerState<CreateEditTransactionScreen> {
  late TransactionType _type;
  late double _amount;
  String? _categoryId;
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  late DateTime _occurredAt;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSaving = false;

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.initialTransaction;
    _type = tx?.type ?? TransactionType.expense;
    _amount = tx?.amount ?? widget.initialAmount ?? 0;
    _categoryId = tx?.categoryId ?? widget.initialCategoryId;
    _merchantController = TextEditingController(
      text: tx?.merchant ?? widget.initialMerchant ?? '',
    );
    _noteController = TextEditingController(text: tx?.note ?? '');
    _occurredAt = tx?.occurredAt ?? DateTime.now();
    _paymentMethod = tx?.paymentMethod ?? PaymentMethod.cash;
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_occurredAt),
      );
      if (pickedTime != null && mounted) {
        setState(() {
          _occurredAt = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  /// Asks the user what to do when the new transaction looks like an
  /// existing one (same amount, near-identical merchant, within 24 hours).
  /// Returns true when it is safe to continue saving.
  Future<bool> _confirmNotDuplicate(Transaction transaction) async {
    try {
      final repo = ref.read(transactionRepositoryProvider);
      final nearby = await repo.getTransactions(
        filter: TransactionFilter(
          startDate: transaction.occurredAt.subtract(const Duration(hours: 24)),
          endDate: transaction.occurredAt.add(const Duration(hours: 24)),
        ),
      );
      final duplicates = const DuplicateDetector().findDuplicates(
        candidate: transaction,
        existing: nearby,
      );
      if (duplicates.isEmpty) return true;
      if (!mounted) return false;

      final proceed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => _DuplicateWarningDialog(
          duplicates: duplicates,
          categoryName: _categoryNameFor(transaction.categoryId),
        ),
      );
      return proceed ?? false;
    } on Exception catch (_) {
      // Detection is best-effort; never block regular saving.
      return true;
    }
  }

  String _categoryNameFor(String? categoryId) {
    final categories = ref.read(categoriesListProvider);
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return 'Giao dịch';
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền lớn hơn 0')),
      );
      return;
    }

    final categories = ref.read(categoriesListProvider);
    final categoryId =
        _categoryId ?? (categories.isNotEmpty ? categories.first.id : 'other');

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final transaction = Transaction(
      id: widget.initialTransaction?.id ?? IdGenerator.generateV7(),
      type: _type,
      amount: _amount,
      currency: 'VND',
      categoryId: categoryId,
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      occurredAt: _occurredAt,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      paymentMethod: _paymentMethod,
      source: widget.initialTransaction?.source ?? widget.initialSource,
      status: TransactionStatus.confirmed,
      createdAt: widget.initialTransaction?.createdAt ?? now,
      updatedAt: now,
    );

    // Local duplicate check before performing any write. The user decides:
    // the flow never deletes or changes existing data on its own.
    if (!_isEditing) {
      final confirmed = await _confirmNotDuplicate(transaction);
      if (!confirmed) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }
    }

    final controller = ref.read(transactionControllerProvider.notifier);
    final success = _isEditing
        ? await controller.updateTransaction(transaction)
        : await controller.create(transaction: transaction);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu giao dịch thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Expense / Income Segmented Control ──────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Chi tiêu'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Thu nhập'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (set) {
                  setState(() => _type = set.first);
                },
              ),
            ),

            // ── Amount Numpad ───────────────────────────────────────
            AmountNumpad(
              amount: _amount,
              onAmountChanged: (val) => setState(() => _amount = val),
            ),

            const Divider(height: 32),

            // ── Category Section ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Danh mục',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Gap(8),
            CategoryPicker(
              selectedCategoryId: _categoryId,
              onCategorySelected: (cat) => setState(() => _categoryId = cat.id),
            ),

            const Gap(16),

            // ── Details Section ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Merchant input
                  TextField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      labelText: 'Cửa hàng / Người nhận',
                      hintText: 'VD: Highlands Coffee, Vinmart',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const Gap(12),

                  // Date picker tile
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.borderMd,
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: const Text('Thời gian'),
                    trailing: Text(
                      _occurredAt.toDisplayDateTime(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: _pickDate,
                  ),
                  const Gap(12),

                  // Payment method
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Phương thức thanh toán',
                      prefixIcon: Icon(Icons.payment_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PaymentMethod.cash,
                        child: Text('Tiền mặt'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.card,
                        child: Text('Thẻ ngân hàng'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.transfer,
                        child: Text('Chuyển khoản'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.ewallet,
                        child: Text('Ví điện tử'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.other,
                        child: Text('Khác'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                  const Gap(12),

                  // Note input
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Thêm ghi chú...',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    maxLines: 2,
                  ),
                  const Gap(24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Warning dialog listing potential duplicate transactions.
class _DuplicateWarningDialog extends StatelessWidget {
  const _DuplicateWarningDialog({
    required this.duplicates,
    required this.categoryName,
  });

  final List<DuplicateMatch> duplicates;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colorScheme.error,
        size: 32,
      ),
      title: const Text('Phát hiện giao dịch trùng'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đã có giao dịch tương tự trong vòng 24 giờ '
              '(cùng số tiền, cửa hàng gần giống):',
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(12),
            for (var i = 0; i < duplicates.length && i < 3; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        '${duplicates[i].existing.merchant ?? categoryName} '
                        '· ${duplicates[i].existing.amount.toVnd()} · '
                        '${duplicates[i].existing.occurredAt.toDisplayDateTime()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Gap(12),
            Text(
              'Bạn vẫn muốn lưu giao dịch này chứ?',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Vẫn lưu'),
        ),
      ],
    );
  }
}
