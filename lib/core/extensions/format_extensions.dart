import 'package:intl/intl.dart';

extension CurrencyFormatX on double {
  /// Format as Vietnamese Dong: 1.234.500đ
  String toVnd() {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(this)}đ';
  }

  /// Format with explicit currency symbol
  String toCurrency(String currency) {
    if (currency == 'VND') return toVnd();
    return NumberFormat.currency(symbol: currency).format(this);
  }
}

extension DateTimeFormatX on DateTime {
  /// "Hôm nay", "Hôm qua", or "dd MMM yyyy"
  String toRelativeLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);
    final diff = today.difference(date).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    return DateFormat('dd MMM yyyy', 'vi_VN').format(this);
  }

  String toDisplayDate() => DateFormat('dd/MM/yyyy').format(this);
  String toDisplayTime() => DateFormat('HH:mm').format(this);
  String toDisplayDateTime() => DateFormat('HH:mm · dd/MM/yyyy').format(this);

  /// Start of current month
  DateTime get startOfMonth => DateTime(year, month);

  /// End of current month (last millisecond)
  DateTime get endOfMonth =>
      DateTime(year, month + 1).subtract(const Duration(milliseconds: 1));
}

extension StringX on String {
  bool get isNotBlankOrEmpty => trim().isNotEmpty;

  /// Parse VND string "1.234.500đ" or "1234500" → double
  double? toVndAmount() {
    final cleaned = replaceAll(RegExp(r'[đ,.đ\s]'), '').trim();
    return double.tryParse(cleaned);
  }
}
