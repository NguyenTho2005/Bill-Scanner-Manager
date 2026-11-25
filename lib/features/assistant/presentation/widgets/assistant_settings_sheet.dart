import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/presentation/providers/assistant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

/// Bottom sheet to configure the optional cloud LLM and review privacy.
class AssistantSettingsSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const AssistantSettingsSheet({super.key});

  /// Opens the sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const AssistantSettingsSheet(),
    );
  }

  @override
  ConsumerState<AssistantSettingsSheet> createState() =>
      _AssistantSettingsSheetState();
}

class _AssistantSettingsSheetState
    extends ConsumerState<AssistantSettingsSheet> {
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();
  AssistantCloudProvider _provider = AssistantCloudProvider.openAiCompatible;
  bool _obscureKey = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final settings = ref.read(assistantSettingsProvider).valueOrNull ??
        const AssistantSettings();
    _provider = settings.provider;
    _baseUrlController.text = settings.baseUrl;
    _modelController.text = settings.model;
    _apiKeyController.text = settings.apiKey;
    _initialized = true;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _toggleCloud(bool enabled) async {
    if (!enabled) {
      await ref
          .read(assistantSettingsProvider.notifier)
          .setCloudEnabled(enabled: false);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Bật trợ lý AI cloud?'),
        content: const Text(
          'Khi bật, những câu hỏi mà trợ lý offline không hiểu sẽ được gửi '
          'tới nhà cung cấp AI bạn cấu hình, kèm bản tóm tắt chi tiêu '
          '(tổng theo tháng, danh mục, ngân sách, số tiền — không gồm ảnh '
          'hóa đơn hay API key của app).\n\n'
          'Bạn có thể tắt bất cứ lúc nào; khi tắt, mọi câu trả lời lại được '
          'xử lý hoàn toàn trên thiết bị.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Để sau'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tôi đồng ý'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(assistantSettingsProvider.notifier)
        .setCloudEnabled(enabled: true);
  }

  void _onProviderChanged(AssistantCloudProvider provider) {
    if (provider == _provider) return;

    final previousBaseUrl = AssistantSettings.defaultBaseUrlFor(_provider);
    final previousModel = AssistantSettings.defaultModelFor(_provider);
    final currentBaseUrl = _baseUrlController.text.trim();
    final currentModel = _modelController.text.trim();

    setState(() {
      _provider = provider;
      if (currentBaseUrl.isEmpty || currentBaseUrl == previousBaseUrl) {
        _baseUrlController.text = AssistantSettings.defaultBaseUrlFor(provider);
      }
      if (currentModel.isEmpty || currentModel == previousModel) {
        _modelController.text = AssistantSettings.defaultModelFor(provider);
      }
    });
  }

  Future<void> _save() async {
    await ref.read(assistantSettingsProvider.notifier).saveConfig(
          provider: _provider,
          baseUrl: _baseUrlController.text,
          model: _modelController.text,
          apiKey: _apiKeyController.text,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu cấu hình trợ lý')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final settingsAsync = ref.watch(assistantSettingsProvider);
    final settings = settingsAsync.valueOrNull ?? const AssistantSettings();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trợ lý AI',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(4),
            Text(
              'Mặc định trợ lý chạy hoàn toàn trên thiết bị. Cloud AI là tuỳ chọn.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const Gap(16),

            // ── Cloud toggle ──────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: SwitchListTile.adaptive(
                value: settings.cloudEnabled,
                onChanged: _toggleCloud,
                title: const Text('Trợ lý AI cloud (tuỳ chọn)'),
                subtitle: const Text(
                  'Trả lời câu hỏi tự do bằng LLM bạn tự cấu hình',
                ),
                secondary: const Icon(Icons.cloud_outlined),
              ),
            ),
            const Gap(16),

            if (settings.cloudEnabled) ...[
              Text(
                'Nhà cung cấp AI',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              SegmentedButton<AssistantCloudProvider>(
                segments: const [
                  ButtonSegment(
                    value: AssistantCloudProvider.openAiCompatible,
                    label: Text('OpenAI'),
                    icon: Icon(Icons.hub_outlined),
                  ),
                  ButtonSegment(
                    value: AssistantCloudProvider.gemini,
                    label: Text('Gemini'),
                    icon: Icon(Icons.auto_awesome_outlined),
                  ),
                ],
                selected: {_provider},
                onSelectionChanged: (selection) =>
                    _onProviderChanged(selection.first),
              ),
              const Gap(16),
              Text(
                _provider == AssistantCloudProvider.gemini
                    ? 'Kết nối Gemini'
                    : 'Endpoint & khoá API',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              TextField(
                controller: _baseUrlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Base URL',
                  hintText: AssistantSettings.defaultBaseUrlFor(_provider),
                  helperText: _provider == AssistantCloudProvider.gemini
                      ? 'Google AI Studio · generativelanguage.googleapis.com'
                      : 'Tương thích OpenAI Chat Completions',
                ),
              ),
              const Gap(12),
              TextField(
                controller: _modelController,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Model',
                  hintText: AssistantSettings.defaultModelFor(_provider),
                  helperText: _provider == AssistantCloudProvider.gemini
                      ? 'Ví dụ: gemini-2.5-flash, gemini-2.5-pro'
                      : null,
                ),
              ),
              const Gap(12),
              TextField(
                controller: _apiKeyController,
                obscureText: _obscureKey,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: _provider == AssistantCloudProvider.gemini
                      ? 'Gemini API key'
                      : 'API key',
                  helperText: _provider == AssistantCloudProvider.gemini
                      ? 'Tạo key tại aistudio.google.com/apikey · '
                          'lưu trong secure storage'
                      : 'Lưu trong secure storage của thiết bị',
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    icon: Icon(
                      _obscureKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              ),
              const Gap(16),
            ],

            // ── Privacy note ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.secondaryContainer.withAlpha(90),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: colors.onSecondaryContainer,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'Offline (mặc định): không có dữ liệu nào rời khỏi máy. '
                      'Câu hỏi về tổng chi, danh mục, ngân sách, so sánh tháng '
                      'và tạo giao dịch luôn được tính tại chỗ, kể cả khi đã bật '
                      'cloud.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Lưu cấu hình'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
