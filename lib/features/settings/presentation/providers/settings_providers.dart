import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/security/security_service.dart';
import 'package:bill_tracker/core/storage/data_management_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [DataManagementService].
final dataManagementServiceProvider = Provider<DataManagementService>((ref) {
  return getIt<DataManagementService>();
});

/// Provider for [SecurityService].
final securityServiceProvider = Provider<SecurityService>((ref) {
  return getIt<SecurityService>();
});

/// Storage usage metrics provider.
final storageUsageProvider =
    FutureProvider.autoDispose<StorageUsageInfo>((ref) async {
  final service = ref.watch(dataManagementServiceProvider);
  return service.getStorageUsage();
});

/// Biometric lock enabled setting.
final isBiometricEnabledProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final security = ref.watch(securityServiceProvider);
  return security.isLockEnabled;
});

/// Privacy setting: whether to keep original captured photos.
final keepOriginalPhotosProvider = StateProvider<bool>((ref) => false);

/// Cloud sync setting: optional, disabled by default in local-first MVP.
final cloudSyncEnabledProvider = StateProvider<bool>((ref) => false);
