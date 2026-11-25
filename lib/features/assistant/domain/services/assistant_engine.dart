import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_block.dart';
import 'package:bill_tracker/features/assistant/domain/entities/assistant_reply.dart';
import 'package:bill_tracker/features/assistant/domain/services/assistant_nlu.dart';
import 'package:bill_tracker/features/assistant/domain/services/chat_expense_draft_parser.dart';
import 'package:bill_tracker/features/budget/domain/repositories/budget_repository.dart';
import 'package:bill_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/category_repository.dart';
import 'package:bill_tracker/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:intl/intl.dart';

/// Compact financial context sent to an opt-in cloud LLM.
class FinancialSnapshot {
  /// Creates a [FinancialSnapshot].
  const FinancialSnapshot({required this.text, required this.generatedAt});

  /// Human-readable, token-efficient summary of local data.
  final String text;

  /// When the snapshot was produced.
  final DateTime generatedAt;
}

/// The on-device "brain" of the assistant.
///
/// Every structured answer is computed locally from the Drift database.
/// [`buildSnapshot`] exists only for the optional cloud LLM path.
class AssistantEngine {
  /// Creates an [AssistantEngine].
  AssistantEngine({
    required this.transactionRepository,
    required this.categoryRepository,
    required this.reportRepository,
    required this.budgetRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Source of transactions.
  final TransactionRepository transactionRepository;

  /// Source of categories (used for NLU and draft parsing).
  final CategoryRepository categoryRepository;

  /// Source of monthly aggregates.
  final ReportRepository reportRepository;

  /// Source of budget progress.
  final BudgetRepository budgetRepository;

  final DateTime Function() _clock;

  static const _defaultSuggestions = [
    'Tháng này tôi tiêu bao nhiêu?',
    'Top 5 khoản chi lớn nhất',
    'Chi tiêu theo danh mục',
    'Ngân sách còn lại',
  ];

  /// Understands [input] without any network call.
  Future<AssistantQuery> understand(String input) async {
    final categories = await categoryRepository.getAllCategories();
    return AssistantNlu(categories: categories).parse(input, now: _clock());
  }

  /// Produces a fully local reply for an already-understood [query].
  Future<AssistantReply> respondTo(AssistantQuery query) async {
    switch (query.intent) {
      case AssistantIntent.greeting:
        return _greeting();
      case AssistantIntent.help:
        return _help();
      case AssistantIntent.totalSpend:
        return _total(query);
      case AssistantIntent.incomeReport:
        return _income(query);
      case AssistantIntent.topExpenses:
        return _top(query);
      case AssistantIntent.categoryBreakdown:
        return _breakdown(query);
      case AssistantIntent.countTransactions:
        return _count(query);
      case AssistantIntent.compareMonths:
        return _compare(query);
      case AssistantIntent.budgetStatus:
        return _budgets();
      case AssistantIntent.recentTransactions:
        return _recent(query);
      case AssistantIntent.createTransaction:
        return _draft(query);
      case AssistantIntent.support:
        return _support();
      case AssistantIntent.unknown:
        return _fallback();
    }
  }

  /// Builds a compact summary of the last [months] months for the cloud LLM.
  Future<FinancialSnapshot> buildSnapshot({int months = 4}) async {
    final now = _clock();
    final dayFormat = DateFormat('dd/MM/yyyy');
    final buffer = StringBuffer()
      ..writeln('Hôm nay: ${dayFormat.format(now)}')
      ..writeln('Tiền tệ: VND');

    final monthly = <String>[];
    for (var offset = 0; offset < months; offset++) {
      final month = DateTime(now.year, now.month - offset);
      final report = await reportRepository.getMonthlyReport(month);
      monthly.add(
        'T${month.month}/${month.year}: chi ${report.totalExpense.toVnd()}, '
        'thu ${report.totalIncome.toVnd()}, '
        '${report.categorySpendings.length} danh mục',
      );
    }
    buffer.writeln('Tổng theo tháng (mới nhất trước):');
    monthly.forEach(buffer.writeln);

    final current = await reportRepository.getMonthlyReport(
      DateTime(now.year, now.month),
    );
    if (current.categorySpendings.isNotEmpty) {
      buffer.writeln('Chi tiết tháng này theo danh mục:');
      for (final item in current.categorySpendings.take(8)) {
        buffer.writeln(
          '- ${item.category.name}: ${item.amount.toVnd()} '
          '(${item.percentage.toStringAsFixed(1)}%, '
          '${item.transactionCount} giao dịch)',
        );
      }
      buffer.writeln('Top khoản chi lớn nhất tháng này:');
      for (final transaction in current.topExpenses.take(5)) {
        buffer.writeln(
          '- ${transaction.occurredAt.toDisplayDate()} '
          '${transaction.category?.name ?? 'Khác'}: '
          '${transaction.amount.toVnd()}',
        );
      }
    }

    try {
      final budgets = await budgetRepository
          .watchBudgetProgressList(month: DateTime(now.year, now.month))
          .first;
      if (budgets.isNotEmpty) {
        buffer.writeln('Ngân sách tháng này:');
        for (final item in budgets) {
          buffer.writeln(
            '- ${item.category.name}: đã chi ${item.spentAmount.toVnd()} / '
            'hạn mức ${item.budget.amountLimit.toVnd()} '
            '(${item.percent}%${item.isExceeded ? ', vượt' : ''})',
          );
        }
      }
    } on Object {
      // Budgets are optional context; ignore failures.
    }

    return FinancialSnapshot(text: buffer.toString(), generatedAt: now);
  }

  // ── Money questions ─────────────────────────────────────────────────

  Future<AssistantReply> _total(AssistantQuery query) async {
    final transactions = await _load(query, type: TransactionType.expense);
    final all = await _load(query);
    final expenses = transactions;
    final incomeTotal = all
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenseTotal =
        expenses.fold<double>(0, (sum, item) => sum + item.amount);

    final scope = query.category != null
        ? ' cho ${query.category!.name.toLowerCase()}'
        : '';

    if (all.isEmpty) {
      return AssistantReply(
        text: 'Trong ${query.timeframe.label.toLowerCase()} mình chưa thấy '
            'giao dịch nào$scope. Bạn thêm bằng nút + hoặc nhắn '
            '"cà phê 45k" để mình ghi nhanh nhé.',
        suggestions: const [
          'Cà phê 45k',
          'Bạn làm được gì?',
        ],
      );
    }

    final days = query.timeframe.endExclusive
        .difference(query.timeframe.start)
        .inDays
        .clamp(1, 3660);
    final perDay = expenseTotal / days;

    final rows = <MetricRow>[
      MetricRow(
        label: 'Tổng chi$scope',
        value: expenseTotal.toVnd(),
        hint: '${expenses.length} giao dịch',
      ),
      if (query.category == null)
        MetricRow(
          label: 'Tổng thu',
          value: incomeTotal.toVnd(),
          hint: incomeTotal == 0 ? 'Chưa ghi nhận' : 'Trong kỳ',
        ),
      if (days >= 2)
        MetricRow(
          label: 'Trung bình mỗi ngày',
          value: perDay.toVnd(),
          hint: '$days ngày',
        ),
      if (query.category == null)
        MetricRow(
          label: 'Chênh lệch thu - chi',
          value: (incomeTotal - expenseTotal).toVnd(),
        ),
    ];

    final headline = expenseTotal == 0
        ? 'Trong ${query.timeframe.label.toLowerCase()} bạn chưa chi đồng nào$scope.'
        : 'Trong ${query.timeframe.label.toLowerCase()}, bạn đã chi '
            '${expenseTotal.toVnd()}$scope qua ${expenses.length} giao dịch.';

    return AssistantReply(
      text: headline,
      blocks: [MetricBlock(title: 'Tổng quan', rows: rows)],
      suggestions: _defaultSuggestions,
    );
  }

  Future<AssistantReply> _income(AssistantQuery query) async {
    final transactions = await _load(query, type: TransactionType.income);
    final total =
        transactions.fold<double>(0, (sum, item) => sum + item.amount);
    if (transactions.isEmpty) {
      return AssistantReply(
        text: 'Trong ${query.timeframe.label.toLowerCase()} mình chưa thấy '
            'khoản thu nào. Bạn có thể nhắn "nhận lương 15 triệu" để ghi.',
        suggestions: const ['Tháng này tôi tiêu bao nhiêu?'],
      );
    }
    return AssistantReply(
      text: 'Trong ${query.timeframe.label.toLowerCase()}, bạn ghi nhận '
          '${transactions.length} khoản thu, tổng ${total.toVnd()}.',
      blocks: [
        TransactionsBlock(
          title: 'Các khoản thu',
          items: transactions
              .take(query.limit)
              .map(TransactionPreview.fromTransaction)
              .toList(),
          totalAmount: total,
        ),
      ],
      suggestions: const ['Tháng này tôi tiêu bao nhiêu?', 'Ngân sách còn lại'],
    );
  }

  Future<AssistantReply> _top(AssistantQuery query) async {
    final expenses = await _load(query, type: TransactionType.expense);
    if (expenses.isEmpty) {
      return AssistantReply(
        text:
            'Chưa có khoản chi nào trong ${query.timeframe.label.toLowerCase()}.',
        suggestions: _defaultSuggestions,
      );
    }
    final sorted = [...expenses]..sort((a, b) => b.amount.compareTo(a.amount));
    final top = sorted.take(query.limit).toList();
    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final share = total == 0
        ? 0.0
        : top.fold<double>(0, (sum, item) => sum + item.amount) / total * 100;

    return AssistantReply(
      text: 'Top ${top.length} khoản chi lớn nhất trong '
          '${query.timeframe.label.toLowerCase()} chiếm '
          '${share.toStringAsFixed(0)}% tổng chi tiêu.',
      blocks: [
        TransactionsBlock(
          title: 'Khoản chi lớn nhất',
          items: top.map(TransactionPreview.fromTransaction).toList(),
          totalAmount: top.fold<double>(0, (sum, item) => sum + item.amount),
        ),
      ],
      suggestions: const [
        'Chi tiêu theo danh mục',
        'So với tháng trước',
      ],
    );
  }

  Future<AssistantReply> _breakdown(AssistantQuery query) async {
    final expenses = await _load(query, type: TransactionType.expense);
    if (expenses.isEmpty) {
      return AssistantReply(
        text: 'Chưa có dữ liệu chi tiêu trong '
            '${query.timeframe.label.toLowerCase()} để phân tích danh mục.',
        suggestions: _defaultSuggestions,
      );
    }

    final total = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    final grouped =
        <String, ({double amount, int count, String name, int color})>{};
    for (final transaction in expenses) {
      final name = transaction.category?.name ?? 'Khác';
      final color = transaction.category?.colorValue ?? 0xFF9E9E9E;
      final previous = grouped[name];
      grouped[name] = (
        amount: (previous?.amount ?? 0) + transaction.amount,
        count: (previous?.count ?? 0) + 1,
        name: name,
        color: color,
      );
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.amount.compareTo(a.value.amount));
    final top = entries.first;

    final rows = entries
        .map(
          (entry) => MetricRow(
            label: entry.value.name,
            value: entry.value.amount.toVnd(),
            hint: '${(entry.value.amount / total * 100).toStringAsFixed(0)}%'
                ' · ${entry.value.count} giao dịch',
          ),
        )
        .toList();

    return AssistantReply(
      text: 'Trong ${query.timeframe.label.toLowerCase()}, '
          '${top.value.name} chiếm nhiều nhất với ${top.value.amount.toVnd()} '
          '(${(top.value.amount / total * 100).toStringAsFixed(0)}% tổng chi). '
          'Tổng cộng ${rows.length} danh mục.',
      blocks: [MetricBlock(title: 'Phân bổ theo danh mục', rows: rows)],
      suggestions: const [
        'Top 5 khoản chi lớn nhất',
        'Ngân sách còn lại',
      ],
    );
  }

  Future<AssistantReply> _count(AssistantQuery query) async {
    final all = await _load(query);
    if (all.isEmpty) {
      return AssistantReply(
        text:
            'Không có giao dịch nào trong ${query.timeframe.label.toLowerCase()}.',
        suggestions: _defaultSuggestions,
      );
    }
    final expenses = all.where((item) => item.type == TransactionType.expense);
    final incomes = all.where((item) => item.type == TransactionType.income);
    return AssistantReply(
      text: 'Trong ${query.timeframe.label.toLowerCase()} có '
          '${all.length} giao dịch: ${expenses.length} khoản chi và '
          '${incomes.length} khoản thu.',
      suggestions: _defaultSuggestions,
    );
  }

  Future<AssistantReply> _compare(AssistantQuery query) async {
    // Normalise "this month" windows; other windows compare with the equally
    // long preceding period.
    DateTime currentStart;
    DateTime currentEnd;
    DateTime previousStart;
    DateTime previousEnd;
    String currentLabel;
    String previousLabel;

    if (query.timeframe.isSingleMonth) {
      currentStart = query.timeframe.start;
      currentEnd = query.timeframe.endExclusive;
      previousStart = DateTime(currentStart.year, currentStart.month - 1);
      previousEnd = currentStart;
      currentLabel = 'Tháng ${currentStart.month}';
      previousLabel = 'Tháng ${previousStart.month}';
    } else {
      final span =
          query.timeframe.endExclusive.difference(query.timeframe.start);
      currentStart = query.timeframe.start;
      currentEnd = query.timeframe.endExclusive;
      previousEnd = currentStart;
      previousStart = currentStart.subtract(span);
      currentLabel = query.timeframe.label;
      previousLabel = 'Kỳ trước';
    }

    final currentTransactions = await transactionRepository.getTransactions(
      filter: TransactionFilter(
        startDate: currentStart,
        endDate: currentEnd.subtract(const Duration(milliseconds: 1)),
        categoryId: query.category?.id,
      ),
    );
    final previousTransactions = await transactionRepository.getTransactions(
      filter: TransactionFilter(
        startDate: previousStart,
        endDate: previousEnd.subtract(const Duration(milliseconds: 1)),
        categoryId: query.category?.id,
      ),
    );

    double sumExpenses(List<Transaction> items) => items
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final currentTotal = sumExpenses(currentTransactions);
    final previousTotal = sumExpenses(previousTransactions);

    if (currentTotal == 0 && previousTotal == 0) {
      return AssistantReply(
        text: 'Chưa có đủ dữ liệu để so sánh $currentLabel và $previousLabel.',
        suggestions: _defaultSuggestions,
      );
    }

    final scope = query.category != null
        ? ' cho ${query.category!.name.toLowerCase()}'
        : '';
    final difference = currentTotal - previousTotal;
    final percent =
        previousTotal == 0 ? null : difference / previousTotal * 100;
    final direction = difference > 0
        ? 'tăng'
        : difference < 0
            ? 'giảm'
            : 'không đổi';

    final headline = percent == null
        ? '$currentLabel bạn chi ${currentTotal.toVnd()}$scope, '
            '$previousLabel chưa có khoản chi nào.'
        : '$currentLabel bạn chi ${currentTotal.toVnd()}$scope, '
            '$previousLabel là ${previousTotal.toVnd()}. '
            'Như vậy $direction ${percent.abs().toStringAsFixed(0)}% '
            '(${difference.abs().toVnd()}).';

    return AssistantReply(
      text: headline,
      blocks: [
        MetricBlock(
          title: 'So sánh chi tiêu$scope',
          rows: [
            MetricRow(label: currentLabel, value: currentTotal.toVnd()),
            MetricRow(label: previousLabel, value: previousTotal.toVnd()),
            MetricRow(
              label: 'Chênh lệch',
              value: '${difference >= 0 ? '+' : '-'}'
                  '${difference.abs().toVnd()}',
              hint: percent == null
                  ? null
                  : '${percent >= 0 ? '+' : ''}'
                      '${percent.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
      suggestions: const [
        'Chi tiêu theo danh mục',
        'Top 5 khoản chi lớn nhất',
      ],
    );
  }

  Future<AssistantReply> _budgets() async {
    final now = _clock();
    final progress = await budgetRepository
        .watchBudgetProgressList(month: DateTime(now.year, now.month))
        .first;

    if (progress.isEmpty) {
      return AssistantReply(
        text: 'Bạn chưa đặt ngân sách nào cho tháng ${now.month}. '
            'Vào tab Ngân sách để tạo hạn mức theo danh mục, '
            'mình sẽ theo dõi và nhắc khi gần vượt.',
        suggestions: const ['Tháng này tôi tiêu bao nhiêu?'],
      );
    }

    final exceeded = progress.where((item) => item.isExceeded).toList();
    final near = progress.where((item) => item.isNearLimit).toList();
    final rows = progress
        .map(
          (item) => MetricRow(
            label: item.category.name,
            value: '${item.spentAmount.toVnd()} / '
                '${item.budget.amountLimit.toVnd()}',
            hint: item.isExceeded
                ? 'Vượt ${(item.spentAmount - item.budget.amountLimit).toVnd()}'
                    ' (${item.percent}%)'
                : 'Còn ${item.remainingAmount.toVnd()}'
                    ' (${item.percent}% đã dùng)',
          ),
        )
        .toList();

    final headline = exceeded.isNotEmpty
        ? 'Có ${exceeded.length} ngân sách đã vượt giới hạn: '
            '${exceeded.map((item) => item.category.name).join(', ')}.'
            '${near.isEmpty ? '' : ' ${near.length} danh mục sắp chạm ngưỡng 80%.'}'
        : near.isNotEmpty
            ? '${near.length} danh mục sắp chạm ngưỡng: '
                '${near.map((item) => item.category.name).join(', ')}.'
            : 'Tất cả ${progress.length} ngân sách vẫn trong giới hạn. '
                'Bạn đang kiểm soát tốt đấy!';

    return AssistantReply(
      text: headline,
      blocks: [MetricBlock(title: 'Ngân sách tháng ${now.month}', rows: rows)],
      suggestions: const [
        'Chi tiêu theo danh mục',
        'Top 5 khoản chi lớn nhất',
      ],
    );
  }

  Future<AssistantReply> _recent(AssistantQuery query) async {
    final all = await transactionRepository.getTransactions(
      filter: TransactionFilter(
        startDate: query.timeframe.start,
        endDate: query.timeframe.endInclusive,
        categoryId: query.category?.id,
      ),
    );
    if (all.isEmpty) {
      return AssistantReply(
        text:
            'Chưa có giao dịch nào trong ${query.timeframe.label.toLowerCase()}.',
        suggestions: _defaultSuggestions,
      );
    }
    final recent = all.take(query.limit).toList();
    return AssistantReply(
      text: '${recent.length} giao dịch gần nhất trong '
          '${query.timeframe.label.toLowerCase()}:',
      blocks: [
        TransactionsBlock(
          title: 'Giao dịch gần đây',
          items: recent.map(TransactionPreview.fromTransaction).toList(),
        ),
      ],
      suggestions: const [
        'Tháng này tôi tiêu bao nhiêu?',
        'Chi tiêu theo danh mục',
      ],
    );
  }

  Future<AssistantReply> _draft(AssistantQuery query) async {
    final categories = await categoryRepository.getAllCategories();
    final draft = ChatExpenseDraftParser(categories: categories)
        .parse(query.raw, now: _clock());

    if (draft == null || !draft.isSavable) {
      return const AssistantReply(
        text: 'Mình chưa đọc được số tiền trong tin nhắn. '
            'Bạn thử lại theo mẫu: "cà phê 45k", "grab 60k hôm qua", '
            '"nhận lương 15 triệu".',
        suggestions: ['Cà phê 45k', 'Grab 60k hôm qua'],
      );
    }

    final isIncome = draft.type == TransactionType.income;
    final label = isIncome ? 'khoản thu' : 'khoản chi';
    final notePart = draft.note == null ? '' : ' cho "${draft.note}"';

    return AssistantReply(
      text: 'Mình hiểu đây là $label ${draft.amount.toVnd()}$notePart vào '
          '${draft.occurredAt.toDisplayDate()}, danh mục ${draft.categoryName}. '
          'Kiểm tra rồi bấm "Lưu giao dịch" nhé.',
      blocks: [DraftBlock(draft: draft)],
    );
  }

  AssistantReply _greeting() {
    return const AssistantReply(
      text: 'Chào bạn 👋 Mình là trợ lý chi tiêu của BillTracker.\n\n'
          'Mình trả lời hoàn toàn trên máy: tổng chi, danh mục, ngân sách, '
          'so sánh tháng, và có thể ghi giao dịch nhanh như "cà phê 45k".',
      suggestions: [
        'Tháng này tôi tiêu bao nhiêu?',
        'Top 5 khoản chi lớn nhất',
        'Ngân sách còn lại',
        'Cà phê 45k',
      ],
    );
  }

  AssistantReply _help() {
    return const AssistantReply(
      text: 'Mình làm được những việc sau, tất cả xử lý trên thiết bị:\n'
          '• Tổng chi/thu: "tháng này tôi tiêu bao nhiêu?"\n'
          '• Khoản lớn nhất: "top 5 khoản chi tháng trước"\n'
          '• Phân bổ danh mục: "chi tiêu theo danh mục"\n'
          '• Ngân sách: "ngân sách còn lại bao nhiêu?"\n'
          '• So sánh: "so với tháng trước thế nào?"\n'
          '• Ghi nhanh: "cà phê 45k", "grab 60k hôm qua"\n'
          '• Hỗ trợ: "báo lỗi", "góp ý" — mình lưu phản hồi kèm chẩn đoán.',
      suggestions: _defaultSuggestions,
    );
  }

  AssistantReply _support() {
    final now = _clock();
    final diagnostics = 'BillTracker 1.0.0\n'
        'Thời điểm: ${now.toDisplayDateTime()}\n'
        'Chế độ dữ liệu: local-only (SQLite)\n'
        'Bạn có thể sao chép thông tin này khi gửi phản hồi.';
    return AssistantReply(
      text: 'Bạn cần hỗ trợ gì cứ nhắn thẳng vào đây nhé — góp ý và báo lỗi '
          'sẽ được lưu cùng thông tin chẩn đoán để bạn gửi đi khi cần.\n\n'
          'Các bước gợi ý: mô tả lỗi + thao tác vừa làm, rồi sao chép chẩn đoán '
          'bên dưới. Kênh liên hệ: support@billtracker.app',
      blocks: [
        NoteBlock(
          text: diagnostics,
          tone: NoteTone.info,
          copyable: true,
        ),
      ],
      suggestions: const [
        'Hướng dẫn sử dụng',
        'Tháng này tôi tiêu bao nhiêu?',
      ],
      isFeedback: true,
    );
  }

  AssistantReply _fallback() {
    return const AssistantReply(
      text: 'Mình chưa hiểu ý này. Bạn có thể hỏi về tổng chi, danh mục, '
          'ngân sách, so sánh tháng — hoặc ghi nhanh một khoản chi.',
      suggestions: [
        'Tháng này tôi tiêu bao nhiêu?',
        'Chi tiêu theo danh mục',
        'Cà phê 45k',
        'Bạn làm được gì?',
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  Future<List<Transaction>> _load(
    AssistantQuery query, {
    TransactionType? type,
  }) async {
    final transactions = await transactionRepository.getTransactions(
      filter: TransactionFilter(
        startDate: query.timeframe.start,
        endDate: query.timeframe.endInclusive,
        categoryId: query.category?.id,
      ),
    );
    if (type == null) return transactions;
    return transactions.where((item) => item.type == type).toList();
  }
}
