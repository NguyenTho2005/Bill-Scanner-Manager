import 'package:bill_tracker/core/analytics/analytics_service.dart';
import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/router/app_router.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Screen managing security, storage, export/import, and privacy settings.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isProcessing = false;

  Future<void> _exportCsv() async {
    setState(() => _isProcessing = true);
    try {
      final service = ref.read(dataManagementServiceProvider);
      final csv = await service.exportDataAsCsv();
      final path = await service.saveExportToFile(
        content: csv,
        extension: 'csv',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất file CSV thành công:\n$path'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xuất CSV: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isProcessing = true);
    try {
      final service = ref.read(dataManagementServiceProvider);
      final json = await service.exportDataAsJson();
      final path = await service.saveExportToFile(
        content: json,
        extension: 'json',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xuất bản sao lưu JSON:\n$path'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi sao lưu JSON: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showImportDialog() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập bản sao lưu JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dán nội dung JSON sao lưu đã xuất trước đó để khôi phục giao dịch và ngân sách:',
            ),
            const Gap(12),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{\n  "app": "BillTracker", ...\n}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && controller.text.trim().isNotEmpty && mounted) {
      setState(() => _isProcessing = true);
      try {
        final service = ref.read(dataManagementServiceProvider);
        final count = await service.importDataFromJson(controller.text.trim());
        ref
          ..invalidate(transactionsStreamProvider)
          ..invalidate(storageUsageProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã khôi phục thành công $count giao dịch!'),
            ),
          );
        }
      } on Object catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi nhập dữ liệu: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmDeleteAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(8),
            const Text('Xác nhận xóa tất cả'),
          ],
        ),
        content: const Text(
          'Hành động này sẽ xóa vĩnh viễn toàn bộ giao dịch, ảnh hóa đơn, ngân sách và dữ liệu cục bộ trên máy.\n\nBạn có chắc chắn muốn tiếp tục không?',
        ),
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
            child: const Text('Xóa toàn bộ dữ liệu'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      setState(() => _isProcessing = true);
      try {
        final service = ref.read(dataManagementServiceProvider);
        await service.deleteAllData();
        ref
          ..invalidate(transactionsStreamProvider)
          ..invalidate(storageUsageProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Toàn bộ dữ liệu và ảnh đã được xóa hoàn toàn.'),
            ),
          );
        }
      } on Object catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa dữ liệu: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final storageAsync = ref.watch(storageUsageProvider);
    final keepOriginal = ref.watch(keepOriginalPhotosProvider);
    final cloudSync = ref.watch(cloudSyncEnabledProvider);
    final isBiometricAsync = ref.watch(isBiometricEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Dữ liệu'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96, top: 12),
        children: [
          // ── Section 1: Security & Privacy ───────────────────────────
          _SectionHeader(title: 'Bảo mật & Quyền riêng tư', theme: theme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Khóa sinh trắc học / PIN'),
                  subtitle: const Text('Yêu cầu Face ID/Vân tay khi mở app'),
                  value: isBiometricAsync.valueOrNull ?? false,
                  onChanged: (val) async {
                    final security = ref.read(securityServiceProvider);
                    await security.setLockEnabled(enabled: val);
                    ref.invalidate(isBiometricEnabledProvider);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded),
                  title: const Text('Thiết lập lại mã PIN'),
                  subtitle: const Text('Đổi mã PIN 4 chữ số bảo mật'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(Routes.lock),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.photo_library_outlined),
                  title: const Text('Lưu ảnh gốc vào thư viện'),
                  subtitle: const Text(
                    'Mặc định chỉ lưu ảnh nén tối ưu (2048px) để tiết kiệm bộ nhớ',
                  ),
                  value: keepOriginal,
                  onChanged: (val) {
                    ref.read(keepOriginalPhotosProvider.notifier).state = val;
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // ── Section 2: Storage & Backup ─────────────────────────────
          _SectionHeader(title: 'Dung lượng & Sao lưu', theme: theme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline_rounded),
                  title: const Text('Bộ nhớ đã sử dụng'),
                  subtitle: storageAsync.when(
                    data: (info) => Text(
                      'Ảnh: ${info.formattedImagesSize} (${info.imagesCount} tệp) · CSDL: ${info.formattedDatabaseSize}',
                    ),
                    loading: () => const Text('Đang tính toán...'),
                    error: (_, __) => const Text('Không thể đọc dung lượng'),
                  ),
                  trailing: storageAsync.when(
                    data: (info) => Text(
                      info.formattedTotalSize,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.table_chart_outlined),
                  title: const Text('Xuất dữ liệu Excel / CSV'),
                  subtitle: const Text('Mở bằng Excel hoặc Google Sheets'),
                  trailing: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  onTap: _isProcessing ? null : _exportCsv,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Sao lưu toàn bộ (JSON)'),
                  subtitle: const Text(
                    'Xuất toàn bộ giao dịch, danh mục, ngân sách',
                  ),
                  trailing: const Icon(Icons.file_download_outlined),
                  onTap: _isProcessing ? null : _exportJson,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_backup_restore_rounded),
                  title: const Text('Khôi phục từ file sao lưu'),
                  subtitle: const Text('Nhập dữ liệu từ bản sao lưu JSON'),
                  trailing: const Icon(Icons.file_upload_outlined),
                  onTap: _isProcessing ? null : _showImportDialog,
                ),
              ],
            ),
          ),
          const Gap(20),

          // ── Section 3: Cloud Sync ───────────────────────────────────
          _SectionHeader(title: 'Đồng bộ hóa đám mây (Tùy chọn)', theme: theme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.offline_pin_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          'Chế độ Local-first an toàn',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Mọi dữ liệu chi tiêu và hình ảnh được lưu trữ an toàn 100% trên thiết bị của bạn. Ứng dụng hoạt động mượt mà hoàn toàn không cần Internet.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Gap(8),
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('Bật đồng bộ đám mây'),
                  subtitle: const Text(
                    'Tùy chọn: Đồng bộ đa thiết bị khi có kết nối',
                  ),
                  value: cloudSync,
                  onChanged: (val) {
                    ref.read(cloudSyncEnabledProvider.notifier).state = val;
                    if (val) {
                      getIt<AnalyticsService>().logEvent(
                        AnalyticsEvents.syncEnabled,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const Gap(20),

          // ── Section 4: Danger Zone ──────────────────────────────────
          _SectionHeader(title: 'Vùng nguy hiểm', theme: theme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: colorScheme.errorContainer.withAlpha(40),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderMd,
              side: BorderSide(
                color: colorScheme.error.withAlpha(80),
              ),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: colorScheme.error,
              ),
              title: Text(
                'Xóa toàn bộ dữ liệu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
              subtitle: const Text(
                'Xóa sạch mọi giao dịch, hình ảnh và ngân sách khỏi máy',
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.error,
              ),
              onTap: _isProcessing ? null : _confirmDeleteAllData,
            ),
          ),
          const Gap(24),

          // ── App Info ────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  'BillTracker',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(4),
                Text(
                  'Phiên bản 1.0.0 · Local-first & Smart Receipt Scanner',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});
  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
