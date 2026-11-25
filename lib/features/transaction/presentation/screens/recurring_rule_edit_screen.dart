import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/recurring_transaction_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/amount_numpad.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

const Map<int, String> _weekdayNames = {
  1: 'Thứ 2',
  2: 'Thứ 3',
  3: 'Thứ 4',
  4: 'Thứ 5',
  5: 'Thứ 6',
  6: 'Thứ 7',
  7: 'Chủ nhật',
};

/// Edit/create screen for [RecurringRule] (add when `ruleId` is absent).
class RecurringRuleEditScreen extends ConsumerStatefulWidget {
  /// Creates [RecurringRuleEditScreen]; omit [ruleId] to add a new rule.
  const RecurringRuleEditScreen({super.key, this.ruleId});

  /// ID of an existing rule to edit.
  final String? ruleId;

  @override
  ConsumerState<RecurringRuleEditScreen> createState() =>
      _RecurringRuleEditScreenState();
}

class _RecurringRuleEditScreenState
    extends ConsumerState<RecurringRuleEditScreen> {
  late double _amount;
  late String _categoryId;
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isActive = true;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  TransactionType _type = TransactionType.expense;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  int? _dayOfMonth;
  int _dayOfWeek = 2; // Monday default
  String? _error;

  static const Map<RecurringFrequency, String> _frequencyNames = {
    RecurringFrequency.daily: 'Hàng ngày',
    RecurringFrequency.weekly: 'Hàng tuần',
    RecurringFrequency.monthly: 'Hàng tháng',
  };

  @override
  void initState() {
    super.initState();
    final repo = ref.read(recurringTransactionRepositoryProvider);
    if (widget.ruleId == null) {
      _amount = 0;
      _categoryId = '';
    } else {
      repo.getById(widget.ruleId!).then((r) {
        if (r == null) return;
        setState(() {
          _amount = r.amount;
          _categoryId = r.categoryId;
          _merchantController.text = r.merchant ?? '';
          _noteController.text = r.note ?? '';
          _type = r.type;
          _frequency = r.frequency;
          _dayOfMonth = r.dayOfMonth;
          if (r.dayOfWeek != null) _dayOfWeek = r.dayOfWeek!;
          _startDate = r.startDate;
          _endDate = r.endDate;
          _isActive = r.isActive;
        });
      });
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      setState(() => _error = 'Vui lòng nhập số tiền lớn hơn 0');
      return;
    }
    if (_categoryId.isEmpty) {
      setState(() => _error = 'Vui lòng chọn danh mục');
      return;
    }
    setState(() => _error = null);

    final nextRunAt = RecurringRule.computeNextRunAt(
      RecurringRule(
        id: widget.ruleId ?? '',
        amount: _amount,
        type: _type,
        currency: 'VND',
        categoryId: _categoryId,
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        dayOfWeek: _dayOfWeek,
        startDate: _startDate,
        nextRunAt: _startDate,
      ),
      DateTime.now(),
    );

    final rule = RecurringRule(
      id: widget.ruleId ?? IdGenerator.generateV7(),
      amount: _amount,
      type: _type,
      currency: 'VND',
      categoryId: _categoryId,
      frequency: _frequency,
      dayOfMonth: _frequency == RecurringFrequency.monthly ? _dayOfMonth : null,
      dayOfWeek: _frequency == RecurringFrequency.weekly ? _dayOfWeek : null,
      startDate: _startDate,
      endDate: _endDate,
      nextRunAt: nextRunAt,
      isActive: _isActive,
    );

    final repo = ref.read(recurringTransactionRepositoryProvider);
    try {
      if (widget.ruleId == null) {
        await repo.save(rule);
      } else {
        await repo.update(rule);
      }
      if (!mounted) return;
      context.pop();
    } on Object catch (e) {
      setState(() => _error = 'Lưu thất bại: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.ruleId == null ? 'Đặt giao dịch định kịt' : 'Sửa quy tắc',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AmountNumpad(
                amount: _amount,
                onAmountChanged: (val) => setState(() => _amount = val),
              ),
              const Gap(8),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Chi tiêu'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Thu nhập'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (set) => setState(() => _type = set.first),
              ),
              const Gap(16),
              Text('Danh mục',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),),
              const Gap(8),
              CategoryPicker(
                selectedCategoryId: _categoryId,
                onCategorySelected: (c) => setState(() => _categoryId = c.id),
              ),
              const Gap(12),
              TextField(
                controller: _merchantController,
                decoration: const InputDecoration(
                  labelText: 'Cửa hàng / Người nhận',
                  hintText: 'VD: Highlands Coffee, Vinmart',
                ),
              ),
              const Gap(8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Ghi chú'),
              ),
              const Gap(16),
              Text('Tần suất', style: theme.textTheme.titleSmall),
              const Gap(8),
              SegmentedButton<RecurringFrequency>(
                segments: _frequencyNames.entries
                    .map((e) => ButtonSegment(value: e.key, label: Text(e.value)))
                    .toList(),
                selected: {_frequency},
                onSelectionChanged: (set) => setState(() => _frequency = set.first),
              ),
              if (_frequency == RecurringFrequency.weekly)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<int>(
                    segments: _weekdayNames.entries
                        .map(
                          (e) => ButtonSegment(value: e.key, label: Text(e.value)),
                        )
                        .toList(),
                    selected: {_dayOfWeek},
                    onSelectionChanged: (set) => setState(() => _dayOfWeek = set.first),
                  ),
                ),
              if (_frequency == RecurringFrequency.monthly)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DropdownButtonFormField<int>(
                    initialValue: _dayOfMonth ?? 28,
                    items: List.generate(
                      28,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                    ),
                    onChanged: (v) => setState(() => _dayOfMonth = v),
                    hint: const Text('Ngày trong tháng'),
                  ),
                ),
              const Gap(16),
              ListTile(
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Bắt đầu từ'),
                trailing: Text(_startDate.toDisplayDate()),
                onTap: _pickStartDate,
              ),
              SwitchListTile(
                title: const Text('Đang hoạt động'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.error),
                  ),
                ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Lưu quy tắc'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
