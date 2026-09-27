import 'dart:io';

import 'package:bill_tracker/core/ai/receipt_ocr_service.dart';
import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
import 'package:bill_tracker/core/widgets/image_source_sheet.dart';
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

      // Store image
      final storage = getIt<ImageStorageService>();
      final storedResult = await storage.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'rcpt',
        keepOriginal: false,
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
          ],
        ),
      ),
    );
  }
}
