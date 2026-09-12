import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Interactive month picker with previous/next buttons.
class MonthPickerBar extends StatelessWidget {
  /// Creates [MonthPickerBar].
  const MonthPickerBar({
    required this.selectedMonth,
    required this.onMonthChanged,
    super.key,
  });

  /// The currently selected month.
  final DateTime selectedMonth;

  /// Callback when selected month changes.
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;

    final formattedLabel =
        DateFormat('MMMM yyyy', 'vi_VN').format(selectedMonth);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.outlined(
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Tháng trước',
            onPressed: () {
              final prev =
                  DateTime(selectedMonth.year, selectedMonth.month - 1);
              onMonthChanged(prev);
            },
          ),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(now.year, now.month + 1),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                onMonthChanged(DateTime(picked.year, picked.month));
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedLabel[0].toUpperCase() +
                        formattedLabel.substring(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton.outlined(
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Tháng sau',
            onPressed: isCurrentMonth
                ? null
                : () {
                    final next = DateTime(
                      selectedMonth.year,
                      selectedMonth.month + 1,
                    );
                    onMonthChanged(next);
                  },
          ),
        ],
      ),
    );
  }
}
