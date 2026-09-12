import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Interactive custom numpad optimized for fast VND currency input.
class AmountNumpad extends StatelessWidget {
  /// Creates [AmountNumpad].
  const AmountNumpad({
    required this.amount,
    required this.onAmountChanged,
    super.key,
    this.currency = 'VND',
    this.maxDigits = 11,
  });

  /// Current raw amount in VND.
  final double amount;

  /// Callback when amount changes.
  final ValueChanged<double> onAmountChanged;

  /// Currency code.
  final String currency;

  /// Maximum digit count (default 11 digits = up to 99 billion VND).
  final int maxDigits;

  void _appendDigit(String digit) {
    HapticFeedback.lightImpact();
    final currentStr = amount == 0 ? '' : amount.toInt().toString();
    if (currentStr.length >= maxDigits) return;

    final newStr = currentStr + digit;
    final newAmount = double.tryParse(newStr) ?? amount;
    onAmountChanged(newAmount);
  }

  void _appendTripleZero() {
    HapticFeedback.lightImpact();
    final currentStr = amount == 0 ? '' : amount.toInt().toString();
    if (currentStr.isEmpty || currentStr.length + 3 > maxDigits) return;

    final newStr = '${currentStr}000';
    final newAmount = double.tryParse(newStr) ?? amount;
    onAmountChanged(newAmount);
  }

  void _backspace() {
    HapticFeedback.selectionClick();
    final currentStr = amount.toInt().toString();
    if (currentStr.isEmpty || currentStr == '0') {
      onAmountChanged(0);
      return;
    }

    final newStr = currentStr.substring(0, currentStr.length - 1);
    final newAmount = newStr.isEmpty ? 0.0 : (double.tryParse(newStr) ?? 0.0);
    onAmountChanged(newAmount);
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    onAmountChanged(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Amount display ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                'Số tiền',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Gap(4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  amount == 0 ? '0đ' : amount.toVnd(),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        amount == 0 ? colorScheme.outline : colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Numpad Grid ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const Gap(8),
              _buildRow(['4', '5', '6']),
              const Gap(8),
              _buildRow(['7', '8', '9']),
              const Gap(8),
              Row(
                children: [
                  _buildKey(
                    child: Text(
                      '000',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: _appendTripleZero,
                  ),
                  const Gap(8),
                  _buildKey(
                    child: Text(
                      '0',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () => _appendDigit('0'),
                  ),
                  const Gap(8),
                  _buildKey(
                    child: const Icon(Icons.backspace_outlined),
                    onTap: _backspace,
                    onLongPress: _clear,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits) {
    return Row(
      children: [
        for (var i = 0; i < digits.length; i++) ...[
          if (i > 0) const Gap(8),
          _buildKey(
            child: Text(
              digits[i],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () => _appendDigit(digits[i]),
          ),
        ],
      ],
    );
  }

  Widget _buildKey({
    required Widget child,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return Expanded(
      child: SizedBox(
        height: 54,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.borderMd,
            onTap: onTap,
            onLongPress: onLongPress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: Colors.grey.withAlpha(50),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
