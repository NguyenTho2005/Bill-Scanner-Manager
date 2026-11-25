import 'dart:io';

import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/core/widgets/image_source_sheet.dart';
import 'package:bill_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:bill_tracker/features/transaction/domain/entities/category.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:bill_tracker/features/transaction/domain/entities/transaction_media.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/category_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/providers/transaction_providers.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/amount_numpad.dart';
import 'package:bill_tracker/features/transaction/presentation/widgets/category_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for scanning paper/electronic receipts, extracting data with OCR, and saving transactions.
class ReceiptScanScreen extends ConsumerStatefulWidget {
  /// Creates [ReceiptScanScreen].
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  bool _isSaving = false;

  File? _imageFile;
  StoredImageResult? _storedResult;
  ReceiptExtractionResult? _extractionResult;

  double _amount = 0;
  String? _selectedCategoryId;
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  late DateTime _occurredAt;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  /// Editable draft of the parsed receipt line items (§4.6 #14).
  List<_LineItemDraft> _lineItemDrafts = [];

  @override
  void initState() {
    super.initState();
    _merchantController = TextEditingController();
    _noteController = TextEditingController();
    _occurredAt = DateTime.now();

    // Show source picker instead of auto-opening camera
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSourcePicker();
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _noteController.dispose();
    for (final draft in _lineItemDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  /// Shows the image source bottom sheet and triggers [_captureReceipt].
  Future<void> _showSourcePicker() async {
    final source = await ImageSourceSheet.show(context);
    if (!mounted) return;
    if (source == null) {
      if (_imageFile == null) context.pop();
      return;
    }
    await _captureReceipt(source);
  }

  Future<void> _captureReceipt(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (picked == null) {
        if (_imageFile == null && mounted) {
          context.pop();
        }
        return;
      }

      setState(() {
        _imageFile = File(picked.path);
        _isProcessing = true;
      });

      final bytes = await _imageFile!.readAsBytes();

      // Store image — honour the privacy setting (§4.6 #17).
      final storage = getIt<ImageStorageService>();
      final storedResult = await storage.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'rcpt',
        keepOriginal: ref.read(keepOriginalPhotosProvider),
      );

      // Run on-device OCR
      final ocrService = getIt<ReceiptOcrService>();
      final extraction =
          await ocrService.extractReceipt(storedResult.compressedPath);

      if (!mounted) return;

      setState(() {
        _storedResult = storedResult;
        _extractionResult = extraction;
        _isProcessing = false;

        // Prefill extracted fields
        if (extraction.total != null) {
          _amount = extraction.total!;
        }
        if (extraction.merchant != null) {
          _merchantController.text = extraction.merchant!;
        }
        if (extraction.transactionDate != null) {
          _occurredAt = extraction.transactionDate!;
        }
        if (extraction.paymentMethod != null) {
          _paymentMethod = _parsePaymentMethod(extraction.paymentMethod!);
        }
        // Default category suggestion for receipts (F&B / bills / shopping)
        _selectedCategoryId = _guessCategory(extraction.merchant);
        for (final draft in _lineItemDrafts) {
          draft.dispose();
        }
        _lineItemDrafts = extraction.lineItems
            .map(_LineItemDraft.fromParsed)
            .toList();
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi quét hóa đơn: $e')),
        );
      }
    }
  }

  PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'card':
        return PaymentMethod.card;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'ewallet':
        return PaymentMethod.ewallet;
      default:
        return PaymentMethod.cash;
    }
  }

  String _guessCategory(String? merchant) {
    if (merchant == null) return 'bills';
    final m = merchant.toLowerCase();
    if (m.contains('coffee') ||
        m.contains('phúc long') ||
        m.contains('highlands') ||
        m.contains('kfc') ||
        m.contains('pizza') ||
        m.contains('jollibee')) {
      return 'food_drinks';
    }
    if (m.contains('winmart') ||
        m.contains('circle k') ||
        m.contains('gs25') ||
        m.contains('bách hóa') ||
        m.contains('co.op')) {
      return 'shopping';
    }
    return 'bills';
  }

  Future<void> _save() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền lớn hơn 0')),
      );
      return;
    }

    final categories = ref.read(categoriesListProvider);
    final categoryId = _selectedCategoryId ??
        (categories.isNotEmpty ? categories.first.id : 'other');

    setState(() => _isSaving = true);

    final transactionId = IdGenerator.generateV7();
    final now = DateTime.now();

    final transaction = Transaction(
      id: transactionId,
      type: TransactionType.expense,
      amount: _amount,
      currency: 'VND',
      categoryId: categoryId,
      merchant: _merchantController.text.trim().isEmpty
          ? null
          : _merchantController.text.trim(),
      occurredAt: _occurredAt,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      paymentMethod: _paymentMethod,
      source: TransactionSource.receiptScan,
      status: (_extractionResult?.requiresReview ?? false)
          ? TransactionStatus.needsReview
          : TransactionStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );

    TransactionMedia? media;
    if (_storedResult != null) {
      media = TransactionMedia(
        id: IdGenerator.generate(),
        transactionId: transactionId,
        type: MediaType.receipt,
        compressedPath: _storedResult!.compressedPath,
        thumbnailPath: _storedResult!.thumbnailPath,
        hash: _storedResult!.hash,
        width: _storedResult!.width,
        height: _storedResult!.height,
        fileSizeBytes: _storedResult!.fileSizeBytes,
        capturedAt: now,
      );
    }

    final controller = ref.read(transactionControllerProvider.notifier);
    final success = await controller.create(
      transaction: transaction,
      media: media,
    );

    // Persist confirmed line items + the OCR extraction (with raw text kept
    // local-only, §4.6 #14/#21). Non-fatal on failure: the transaction
    // itself is already saved.
    if (success && _extractionResult != null) {
      try {
        final repo = ref.read(transactionRepositoryProvider);
        await repo.saveReceiptScanData(
          transactionId: transactionId,
          extraction: _extractionResult!,
          lineItems: _lineItemDrafts
              .where((d) => d.include)
              .map((d) => d.toParsedLineItem())
              .whereType<ParsedLineItem>()
              .toList(),
        );
      } on Exception catch (_) {
        // Swallow: line-item persistence must not block saving the expense.
      }
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lưu giao dịch thất bại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isProcessing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quét hóa đơn')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(
                'Đang nhận diện chữ & số tiền...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                'OCR chạy 100% trên thiết bị của bạn',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_imageFile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quét hóa đơn')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _showSourcePicker,
                icon: const Icon(Icons.document_scanner),
                label: const Text('Chọn nguồn ảnh hóa đơn'),
              ),
            ],
          ),
        ),
      );
    }

    final requiresReview = _extractionResult?.requiresReview ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra hóa đơn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Chụp lại',
            onPressed: _showSourcePicker,
          ),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Lưu',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Review alert banner if confidence is low ──────────────
            if (requiresReview)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error),
                    const Gap(10),
                    Expanded(
                      child: Text(
                        'Độ tin cậy OCR thấp. Vui lòng kiểm tra lại số tiền và tên cửa hàng trước khi lưu.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Photo thumbnail preview ───────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.borderMd,
                    child: Image.file(
                      _imageFile!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _merchantController.text.isEmpty
                              ? 'Hóa đơn mua sắm'
                              : _merchantController.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                        Text(
                          'Thời gian: ${_occurredAt.toDisplayDateTime()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          'Mọi thông tin đều có thể chỉnh sửa',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Amount Numpad ─────────────────────────────────────────
            AmountNumpad(
              amount: _amount,
              onAmountChanged: (val) => setState(() => _amount = val),
            ),

            const Divider(height: 24),

            // ── Category Picker ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Danh mục',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const Gap(8),
            CategoryPicker(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (Category cat) {
                setState(() => _selectedCategoryId = cat.id);
              },
            ),

            const Gap(16),

            // ── Editable Details ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      labelText: 'Cửa hàng / Người nhận',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                  ),
                  const Gap(12),
                  DropdownButtonFormField<PaymentMethod>(
                    initialValue: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Phương thức thanh toán',
                      prefixIcon: Icon(Icons.payment_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PaymentMethod.cash,
                        child: Text('Tiền mặt'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.card,
                        child: Text('Thẻ ngân hàng'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.transfer,
                        child: Text('Chuyển khoản'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.ewallet,
                        child: Text('Ví điện tử'),
                      ),
                      DropdownMenuItem(
                        value: PaymentMethod.other,
                        child: Text('Khác'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _paymentMethod = val);
                    },
                  ),
                  const Gap(12),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      hintText: 'Thêm ghi chú...',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const Gap(24),
                ],
              ),
            ),

            // ── Line Items Editor (§4.6 #14) ─────────────────────────
            if (_lineItemDrafts.isNotEmpty)
              _LineItemsEditorSection(
                drafts: _lineItemDrafts,
                onChanged: () => setState(() {}),
                onAddLine: () =>
                    setState(() => _lineItemDrafts.add(_LineItemDraft.empty())),
                onRemove: (draft) =>
                    setState(() => _lineItemDrafts.remove(draft)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mutable draft of a parsed receipt line item, editable before save
/// (§4.6 #14: user can fix each row in the review screen).
class _LineItemDraft {
  _LineItemDraft({
    required this.nameController,
    required this.quantityController,
    required this.priceController,
    this.include = true,
  });

  factory _LineItemDraft.fromParsed(ParsedLineItem item) {
    return _LineItemDraft(
      nameController: TextEditingController(text: item.name),
      quantityController: TextEditingController(
        text: item.quantity == null
            ? ''
            : (item.quantity == item.quantity!.roundToDouble()
                ? item.quantity!.round().toString()
                : item.quantity!.toStringAsFixed(2)),
      ),
      priceController: TextEditingController(
        text: item.total == 0 ? '' : item.total.round().toString(),
      ),
    );
  }

  factory _LineItemDraft.empty() {
    return _LineItemDraft(
      nameController: TextEditingController(),
      quantityController: TextEditingController(),
      priceController: TextEditingController(),
      include: true,
    );
  }

  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  bool include;

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }

  /// Builds a [ParsedLineItem] from the current draft values; returns null
  /// when the row is incomplete or invalid.
  ParsedLineItem? toParsedLineItem() {
    final name = nameController.text.trim();
    final total = double.tryParse(
      priceController.text.replaceAll(RegExp(r'[.,\s]'), ''),
    );
    if (name.isEmpty || total == null || total <= 0) return null;
    final quantity = double.tryParse(
      quantityController.text.replaceAll(',', '.'),
    );
    final unitPrice = quantity != null && quantity > 0
        ? total / quantity
        : null;
    return ParsedLineItem(
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      confidence: 1, // user-confirmed rows are fully trusted
    );
  }
}

/// Editable list of receipt line items shown in the review screen.
class _LineItemsEditorSection extends StatelessWidget {
  const _LineItemsEditorSection({
    required this.drafts,
    required this.onChanged,
    required this.onAddLine,
    required this.onRemove,
  });

  final List<_LineItemDraft> drafts;
  final VoidCallback onChanged;
  final VoidCallback onAddLine;
  final ValueChanged<_LineItemDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: colorScheme.primary),
              const Gap(8),
              Text(
                'Món hàng trong hóa đơn',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddLine,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm dòng'),
              ),
            ],
          ),
        ),
        const Gap(4),
        ...drafts.map(
          (draft) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: draft.include,
                  onChanged: (val) {
                    draft.include = val ?? true;
                    onChanged();
                  },
                ),
                Expanded(
                  flex: 5,
                  child: TextField(
                    controller: draft.nameController,
                    decoration: const InputDecoration(
                      hintText: 'Tên món',
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const Gap(8),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: draft.quantityController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'SL',
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const Gap(8),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: draft.priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Thành tiền',
                      isDense: true,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  tooltip: 'Xoá dòng',
                  onPressed: () => onRemove(draft),
                ),
              ],
            ),
          ),
        ),
        const Gap(8),
      ],
    );
  }
}
