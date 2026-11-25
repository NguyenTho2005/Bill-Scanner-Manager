import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_settings.dart';
import 'package:bill_tracker/features/assistant/domain/entities/chat_message.dart';
import 'package:bill_tracker/features/assistant/domain/entities/transaction_draft.dart';
import 'package:bill_tracker/features/assistant/domain/repositories/assistant_repository.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_engine.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_responder.dart';
import 'package:bill_tracker/features/assistant/domain/services/llm_client.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the assistant persistence layer.
final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  return getIt<AssistantRepository>();
});

/// Provider for the on-device answer engine.
final assistantEngineProvider = Provider<AssistantEngine>((ref) {
  return AssistantEngine(
    transactionRepository: getIt<TransactionRepository>(),
    categoryRepository: getIt<CategoryRepository>(),
    reportRepository: getIt<ReportRepository>(),
    budgetRepository: getIt<BudgetRepository>(),
  );
});

/// Provider for offline/cloud reply orchestration.
final assistantResponderProvider = Provider<AssistantResponder>((ref) {
  return AssistantResponder(
    engine: ref.watch(assistantEngineProvider),
    llmClient: getIt<LlmClient>(),
  );
});

/// Whether the assistant is currently waiting on an answer.
final assistantThinkingProvider = StateProvider<bool>((ref) => false);

/// Base prompt chips shown in the empty state.
const assistantStarterPrompts = <String>[
  'Tháng này tôi tiêu bao nhiêu?',
  'Top 5 khoản chi lớn nhất',
  'Chi tiêu theo danh mục',
  'Ngân sách còn lại',
  'Cà phê 45k',
];

/// Controls the assistant configuration (offline by default).
class AssistantSettingsController extends AsyncNotifier<AssistantSettings> {
  @override
  Future<AssistantSettings> build() {
    return ref.watch(assistantRepositoryProvider).loadSettings();
  }

  /// Enables or disables cloud mode after the user confirms the warning.
  Future<void> setCloudEnabled({required bool enabled}) async {
    final current = state.valueOrNull ?? const AssistantSettings();
    final updated = current.copyWith(cloudEnabled: enabled);
    await _persist(updated);
  }

  /// Saves provider, endpoint, model and key.
  Future<void> saveConfig({
    required AssistantCloudProvider provider,
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async {
    final current = state.valueOrNull ?? const AssistantSettings();
    final updated = current.copyWith(
      provider: provider,
      baseUrl: baseUrl.trim(),
      model: model.trim(),
      apiKey: apiKey.trim(),
    );
    await _persist(updated);
  }

  Future<void> _persist(AssistantSettings settings) async {
    state = AsyncValue.data(settings);
    await ref.read(assistantRepositoryProvider).saveSettings(settings);
  }
}

/// Provider for assistant configuration.
final assistantSettingsProvider =
    AsyncNotifierProvider<AssistantSettingsController, AssistantSettings>(
  AssistantSettingsController.new,
);

/// Controls the persisted chat conversation.
class AssistantChatController extends AsyncNotifier<List<ChatMessage>> {
  @override
  Future<List<ChatMessage>> build() {
    return ref.watch(assistantRepositoryProvider).loadHistory();
  }

  AssistantRepository get _repository => ref.read(assistantRepositoryProvider);

  /// Sends [raw] as a user message and appends the assistant answer.
  Future<void> send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;

    final messages = [...(state.valueOrNull ?? const <ChatMessage>[])];
    final userMessage = ChatMessage(
      id: IdGenerator.generateV7(),
      role: ChatRole.user,
      text: text,
      createdAt: DateTime.now(),
    );
    messages.add(userMessage);
    state = AsyncValue.data(messages);
    await _repository.saveMessage(userMessage);

    ref.read(assistantThinkingProvider.notifier).state = true;
    try {
      AssistantSettings settings;
      try {
        settings = await ref.read(assistantSettingsProvider.future);
      } on Object {
        settings = const AssistantSettings();
      }
      final reply = await ref.read(assistantResponderProvider).respond(
            input: text,
            settings: settings,
            history: messages,
          );

      final assistantMessage = ChatMessage(
        id: IdGenerator.generateV7(),
        role: ChatRole.assistant,
        text: reply.text,
        createdAt: DateTime.now(),
        blocks: reply.blocks,
        suggestions: reply.suggestions,
        isLocal: !reply.answeredByCloud,
      );

      final updated = [
        ...(state.valueOrNull ?? messages),
        assistantMessage,
      ];
      state = AsyncValue.data(updated);
      await _repository.saveMessage(assistantMessage);

      if (reply.isFeedback) {
        await _markAsFeedback(userMessage.id);
      }
    } on Object catch (error) {
      final failure = ChatMessage(
        id: IdGenerator.generateV7(),
        role: ChatRole.assistant,
        text: 'Xin lỗi, mình gặp lỗi khi xử lý tin nhắn: $error',
        createdAt: DateTime.now(),
        status: ChatMessageStatus.failed,
      );
      state = AsyncValue.data([...(state.valueOrNull ?? messages), failure]);
      await _repository.saveMessage(failure);
    } finally {
      ref.read(assistantThinkingProvider.notifier).state = false;
    }
  }

  /// Saves a draft transaction and updates the corresponding message block.
  Future<bool> confirmDraft(String messageId, TransactionDraft draft) async {
    try {
      final now = DateTime.now();
      final transaction = Transaction(
        id: IdGenerator.generateV7(),
        type: draft.type,
        amount: draft.amount,
        currency: 'VND',
        categoryId: draft.categoryId,
        merchant: null,
        note: draft.note,
        occurredAt: draft.occurredAt,
        source: TransactionSource.manual,
        status: TransactionStatus.confirmed,
        createdAt: now,
        updatedAt: now,
      );
      await ref
          .read(transactionRepositoryProvider)
          .createTransaction(transaction);

      await _updateDraftState(messageId, DraftState.created);

      final label = draft.type == TransactionType.income ? 'thu' : 'chi';
      final confirmation = ChatMessage(
        id: IdGenerator.generateV7(),
        role: ChatRole.assistant,
        text: 'Đã lưu khoản $label ${draft.amount.toVnd()}'
            '${draft.note == null ? '' : ' (${draft.note})'} vào '
            '${draft.occurredAt.toDisplayDate()}.',
        createdAt: DateTime.now(),
        suggestions: const ['Tháng này tôi tiêu bao nhiêu?'],
      );
      state = AsyncValue.data([
        ...(state.valueOrNull ?? const <ChatMessage>[]),
        confirmation,
      ]);
      await _repository.saveMessage(confirmation);
      return true;
    } on Object {
      return false;
    }
  }

  /// Marks a draft as dismissed by the user.
  Future<void> dismissDraft(String messageId) async {
    await _updateDraftState(messageId, DraftState.dismissed);
  }

  /// Deletes the whole conversation.
  Future<void> clear() async {
    await _repository.clearHistory();
    state = const AsyncValue.data([]);
  }

  Future<void> _updateDraftState(
    String messageId,
    DraftState draftState,
  ) async {
    final messages = state.valueOrNull ?? const <ChatMessage>[];
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index < 0) return;

    final target = messages[index];
    final blocks = target.blocks.map((block) {
      if (block is DraftBlock) {
        return block.copyWith(state: draftState);
      }
      return block;
    }).toList();

    final updatedMessage = target.copyWith(blocks: blocks);
    final updated = [...messages];
    updated[index] = updatedMessage;
    state = AsyncValue.data(updated);
    await _repository.saveMessage(updatedMessage);
  }

  Future<void> _markAsFeedback(String messageId) async {
    final messages = state.valueOrNull ?? const <ChatMessage>[];
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index < 0) return;
    final updated = [...messages];
    updated[index] = messages[index].copyWith(isFeedback: true);
    state = AsyncValue.data(updated);
    await _repository.saveMessage(updated[index]);
  }
}

/// Provider for the chat conversation.
final assistantChatProvider =
    AsyncNotifierProvider<AssistantChatController, List<ChatMessage>>(
  AssistantChatController.new,
);
