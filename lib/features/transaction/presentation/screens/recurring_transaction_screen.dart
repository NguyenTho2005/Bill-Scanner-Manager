import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/features/transaction/domain/entities/recurring_rule.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/recurring_transaction_providers.dart';
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

/// Screen managing recurring transaction rules (list, add, toggle, delete).
class RecurringTransactionScreen extends ConsumerWidget {
  /// Creates [RecurringTransactionScreen].
  const RecurringTransactionScreen({super.key});

  String _describeRule(RecurringRule rule) {
    switch (rule.frequency) {
      case RecurringFrequency.daily:
        return 'Mỗi ngày';
      case RecurringFrequency.weekly:
        final weekday = rule.dayOfWeek ?? 1;
        return 'Mỗi tuần ${_weekdayNames[weekday] ?? ''}';
      case RecurringFrequency.monthly:
        final day = rule.dayOfMonth ?? 'cuối';
        return 'Mỗi tháng ngày $day';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(recurringTransactionRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch định kịt')),
      body: FutureBuilder<List<RecurringRule>>(
        future: repo.getAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rules = snapshot.data!;
          if (rules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 56,
                    color: theme.colorScheme.outline,
                  ),
                  const Gap(16),
                  const Text('Chưa có quy tắc nào'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: rules.length,
            itemBuilder: (context, i) {
              final rule = rules[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.repeat_rounded),
                    title: Text('${rule.amount.toVnd()} • ${_describeRule(rule)}'),
                    subtitle: Text(
                      'Từ ${rule.startDate.toDisplayDate()}${rule.endDate != null
                              ? ' – Đến ${rule.endDate!.toDisplayDate()}'
                              : ''}',
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(rule.isActive ? 'Tạm dừng' : 'Mở lại'),
                        ),
                        const PopupMenuItem(value: 'delete', child: Text('Xoá')),
                      ],
                      onSelected: (choice) async {
                        if (choice == 'edit') {
                          await context.push(
                            '${Routes.recurringRuleEdit}/${rule.id}',
                          );
                        } else if (choice == 'toggle') {
                          await repo.setIsActive(
                            rule.id,
                            isActive: !rule.isActive,
                          );
                        } else if (choice == 'delete') {
                          await repo.delete(rule.id);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push(Routes.recurringRuleEdit),
      ),
    );
  }
}
