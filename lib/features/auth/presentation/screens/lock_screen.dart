import 'dart:async';

import 'package:bill_tracker/core/security/security_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Lock screen shown when the app requires authentication.
/// Supports biometric (primary) with PIN fallback.
class LockScreen extends ConsumerStatefulWidget {
  /// Creates [LockScreen].
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _showPinFallback = false;
  bool _isLoading = false;
  String _pinInput = '';
  String? _errorMessage;
  static const _pinLength = 4;

  @override
  void initState() {
    super.initState();
    // Attempt biometric immediately on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryBiometric();
    });
  }

  Future<void> _tryBiometric() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final security = ref.read(securityServiceProvider);
    final result = await security.authenticateWithBiometric(
      reason: 'Xác thực để mở BillTracker',
    );

    if (!mounted) return;

    switch (result) {
      case AuthSuccess():
        ref.read(appLockProvider.notifier).unlock();
      case AuthCancelled():
        // Show PIN fallback if user cancelled biometric
        setState(() {
          _showPinFallback = true;
          _isLoading = false;
        });
      case AuthFailed(:final failure):
        setState(() {
          _showPinFallback = true;
          _isLoading = false;
          _errorMessage = failure.message;
        });
    }
  }

  Future<void> _submitPin() async {
    if (_pinInput.length < _pinLength) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final security = ref.read(securityServiceProvider);
    final result = await security.verifyPin(_pinInput);

    if (!mounted) return;

    switch (result) {
      case AuthSuccess():
        ref.read(appLockProvider.notifier).unlock();
      case AuthFailed(:final failure):
        setState(() {
          _pinInput = '';
          _isLoading = false;
          _errorMessage = failure.message;
        });
        // Vibrate to signal wrong PIN
        unawaited(HapticFeedback.heavyImpact());
      case AuthCancelled():
        setState(() => _isLoading = false);
    }
  }

  void _onNumpadTap(String digit) {
    if (_pinInput.length >= _pinLength) return;
    setState(() {
      _pinInput += digit;
      _errorMessage = null;
    });
    if (_pinInput.length == _pinLength) {
      _submitPin();
    }
  }

  void _onBackspace() {
    if (_pinInput.isEmpty) return;
    setState(() {
      _pinInput = _pinInput.substring(0, _pinInput.length - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // ── App icon / logo ────────────────────────────────────────
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: AppRadius.borderXl,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const Gap(20),
            Text(
              'BillTracker',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Text(
              _showPinFallback ? 'Nhập mã PIN' : 'Xác thực để tiếp tục',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),

            if (_showPinFallback) ...[
              // ── PIN dots ──────────────────────────────────────────────
              _PinDots(
                length: _pinLength,
                filled: _pinInput.length,
                hasError: _errorMessage != null,
              ),
              const Gap(12),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              const Gap(32),
              // ── Numpad ────────────────────────────────────────────────
              _Numpad(
                onDigit: _onNumpadTap,
                onBackspace: _onBackspace,
                isLoading: _isLoading,
              ),
              const Gap(24),
              // ── Biometric retry ───────────────────────────────────────
              TextButton.icon(
                onPressed: _isLoading ? null : _tryBiometric,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Dùng sinh trắc học'),
              ),
            ] else ...[
              if (_isLoading)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: _tryBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Xác thực'),
                ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// PIN indicator dots widget.
class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.length,
    required this.filled,
    required this.hasError,
  });

  final int length;
  final int filled;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = hasError ? colorScheme.error : colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final isFilled = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? dotColor : Colors.transparent,
            border: Border.all(
              color: isFilled ? dotColor : colorScheme.outline,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

/// Numpad widget for PIN entry.
class _Numpad extends StatelessWidget {
  const _Numpad({
    required this.onDigit,
    required this.onBackspace,
    required this.isLoading,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _numRow(['1', '2', '3']),
          const Gap(12),
          _numRow(['4', '5', '6']),
          const Gap(12),
          _numRow(['7', '8', '9']),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72), // spacer
              _NumKey(digit: '0', onTap: onDigit, disabled: isLoading),
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: isLoading ? null : onBackspace,
                  iconSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map((d) => _NumKey(digit: d, onTap: onDigit, disabled: isLoading))
          .toList(),
    );
  }
}

/// Individual numpad key.
class _NumKey extends StatelessWidget {
  const _NumKey({
    required this.digit,
    required this.onTap,
    required this.disabled,
  });

  final String digit;
  final ValueChanged<String> onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderFull,
        child: InkWell(
          borderRadius: AppRadius.borderFull,
          onTap: disabled ? null : () => onTap(digit),
          child: Center(
            child: Text(
              digit,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
    );
  }
}
