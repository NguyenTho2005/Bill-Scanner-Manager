import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/budget/domain/entities/budget.dart';
import 'package:bill_tracker/features/budget/presentation/providers/budget_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Screen to create or edit a category budget.
class CreateEditBudgetScreen extends ConsumerStatefulWidget {
  /// Creates [CreateEditBudgetScreen].
  const CreateEditBudgetScreen({this.budgetId, super.key});

  /// ID of budget if editing, or null if creating.
  final String? budgetId;

  @override
  ConsumerState<CreateEditBudgetScreen> createState() =>
      _CreateEditBudgetScreenState();
}

class _CreateEditBudgetScreenState
    extends ConsumerState<CreateEditBudgetScreen> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  bool _notifyAt80 = true;
  bool _notifyAt100 = true;
  bool _notifyAt120 = true;
  bool _isLoading = false;
  Budget? _existingBudget;

  bool get _isEditing => widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingBudget();
    }
  }

  Future<void> _loadExistingBudget() async {
    final repo = ref.read(budgetRepositoryProvider);
    final b = await repo.getBudgetById(widget.budgetId!);
    if (b != null && mounted) {
      setState(() {
        _existingBudget = b;
        _selectedCategoryId = b.categoryId;
        _amountController.text = b.amountLimit.toInt().toString();
        _notifyAt80 = b.alertThresholds.contains(0.8);
        _notifyAt100 =
            b.alertThresholds.contains(1.0) || b.alertThresholds.contains(1);
        _notifyAt120 = b.alertThresholds.contains(1.2);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _addQuickAmount(int delta) {
    final current = int.tryParse(_amountController.text) ?? 0;
    final updated = current + delta;
    _amountController.text = updated.toString();
  }

  Future<void> _save() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập hạn mức hợp lệ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final periodStart = DateTime(now.year, now.month);
    final periodEnd = DateTime(now.year, now.month + 1)
        .subtract(const Duration(milliseconds: 1));

    final thresholds = <double>[];
    if (_notifyAt80) thresholds.add(0.8);
    if (_notifyAt100) thresholds.add(1);
    if (_notifyAt120) thresholds.add(1.2);

    final budget = Budget(
      id: widget.budgetId ?? 'bg_${DateTime.now().millisecondsSinceEpoch}',
      categoryId: _selectedCategoryId!,
      amountLimit: amount,
      period: 'monthly',
      alertThresholds: thresholds.isEmpty ? const [0.8, 1] : thresholds,
      alertSentAt80: _existingBudget?.alertSentAt80 ?? false,
      alertSentAt100: _existingBudget?.alertSentAt100 ?? false,
      periodStart: _existingBudget?.periodStart ?? periodStart,
      periodEnd: _existingBudget?.periodEnd ?? periodEnd,
    );

    await ref.read(budgetActionNotifierProvider.notifier).saveBudget(budget);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Đã cập nhật ngân sách'
                : 'Đã tạo ngân sách thành công',
          ),
        ),
      );
      context.pop();
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ngân sách này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      setState(() => _isLoading = true);
      await ref
          .read(budgetActionNotifierProvider.notifier)
          .deleteBudget(widget.budgetId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa ngân sách')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa ngân sách' : 'Thiết lập ngân sách mới'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              tooltip: 'Xóa ngân sách',
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Choose Category ──────────────────────────────────────
            Text(
              'Chọn danh mục chi tiêu',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(10),
            CategoryPicker(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (cat) {
                setState(() => _selectedCategoryId = cat.id);
              },
            ),
            const Gap(24),

            // ── Amount Limit Input ───────────────────────────────────
            Text(
              'Hạn mức ngân sách hàng tháng (VND)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.primary,
              ),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: 3000000',
                suffixText: 'đ',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.borderMd,
                ),
              ),
            ),
            const Gap(10),

            // ── Quick Add Buttons ────────────────────────────────────
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('+500.000đ'),
                  onPressed: () => _addQuickAmount(500000),
                ),
                ActionChip(
                  label: const Text('+1.000.000đ'),
                  onPressed: () => _addQuickAmount(1000000),
                ),
                ActionChip(
                  label: const Text('+2.000.000đ'),
                  onPressed: () => _addQuickAmount(2000000),
                ),
                ActionChip(
                  label: const Text('+5.000.000đ'),
                  onPressed: () => _addQuickAmount(5000000),
                ),
              ],
            ),
            const Gap(24),

            // ── Alert Thresholds ─────────────────────────────────────
            Text(
              'Cảnh báo thông báo thông minh',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(4),
            Text(
              'Ứng dụng sẽ gửi thông báo cục bộ khi mức chi tiêu chạm tới các ngưỡng sau:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            CheckboxListTile(
              title: const Text('Cảnh báo khi đạt 80% ngân sách'),
              subtitle:
                  const Text('Nhắc nhở kịp thời trước khi vượt ngân sách'),
              value: _notifyAt80,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _notifyAt80 = val ?? true),
            ),
            CheckboxListTile(
              title: const Text('Cảnh báo khi đạt 100% ngân sách'),
              subtitle: const Text('Thông báo ngay khi đã chi hết hạn mức'),
              value: _notifyAt100,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _notifyAt100 = val ?? true),
            ),
            CheckboxListTile(
              title: const Text('Cảnh báo nghiêm trọng tại 120%'),
              subtitle: const Text('Cảnh báo bội chi tài chính vượt mức'),
              value: _notifyAt120,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _notifyAt120 = val ?? true),
            ),
            const Gap(32),

            // ── Submit Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Lưu thay đổi' : 'Tạo ngân sách',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
