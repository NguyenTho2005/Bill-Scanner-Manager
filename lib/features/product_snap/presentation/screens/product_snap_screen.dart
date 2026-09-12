import 'dart:io';

import 'package:bill_tracker/core/ai/product_classifier.dart';
import 'package:bill_tracker/core/di/injection_container.dart';
import 'package:bill_tracker/core/storage/image_storage_service.dart';
import 'package:bill_tracker/core/theme/app_theme.dart';
import 'package:bill_tracker/core/utils/id_generator.dart';
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

/// Screen for capturing a product snapshot, classifying it with AI, and saving an expense.
class ProductSnapScreen extends ConsumerStatefulWidget {
  /// Creates [ProductSnapScreen].
  const ProductSnapScreen({super.key});

  @override
  ConsumerState<ProductSnapScreen> createState() => _ProductSnapScreenState();
}

class _ProductSnapScreenState extends ConsumerState<ProductSnapScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  bool _isSaving = false;

  File? _imageFile;
  StoredImageResult? _storedResult;
  ProductClassificationResult? _classificationResult;

  double _amount = 0;
  String? _selectedCategoryId;
  final TextEditingController _merchantController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Open camera immediately upon screen launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureImage(ImageSource.camera);
    });
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _captureImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (picked == null) {
        if (_imageFile == null && mounted) {
          // If no image was selected on initial load, pop back
          context.pop();
        }
        return;
      }

      setState(() {
        _imageFile = File(picked.path);
        _isProcessing = true;
      });

      final bytes = await _imageFile!.readAsBytes();

      // Process & store image
      final storage = getIt<ImageStorageService>();
      final storedResult = await storage.processAndStoreImage(
        imageBytes: bytes,
        filePrefix: 'prod',
        keepOriginal: false,
      );

      // Classify with AI
      final classifier = getIt<ProductClassifier>();
      final classification =
          await classifier.classifyImage(storedResult.compressedPath);

      if (!mounted) return;

      setState(() {
        _storedResult = storedResult;
        _classificationResult = classification;
        _isProcessing = false;
        // Pre-select AI suggested category if high confidence
        if (classification.suggestedCategoryId != null) {
          _selectedCategoryId = classification.suggestedCategoryId;
        }
      });
    } on Exception catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý hình ảnh: $e')),
        );
      }
    }
  }

  Future<void> _saveTransaction() async {
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
      occurredAt: now,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      paymentMethod: PaymentMethod.cash,
      source: TransactionSource.productSnap,
      status: TransactionStatus.confirmed,
      createdAt: now,
      updatedAt: now,
    );

    TransactionMedia? media;
    if (_storedResult != null) {
      media = TransactionMedia(
        id: IdGenerator.generate(),
        transactionId: transactionId,
        type: MediaType.product,
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
        appBar: AppBar(title: const Text('Chụp sản phẩm')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const Gap(16),
              Text(
                'Đang nhận diện món đồ...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              Text(
                'AI đang phân tích trên thiết bị của bạn',
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
        appBar: AppBar(title: const Text('Chụp sản phẩm')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => _captureImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Mở camera chụp ảnh'),
              ),
              const Gap(12),
              OutlinedButton.icon(
                onPressed: () => _captureImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh từ thư viện'),
              ),
            ],
          ),
        ),
      );
    }

    final suggestionConf =
        _classificationResult?.suggestedCategoryConfidence ?? 0.0;
    final topLabel = _classificationResult?.labels.isNotEmpty ?? false
        ? _classificationResult!.labels.first.text
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận chi tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Chụp lại',
            onPressed: () => _captureImage(ImageSource.camera),
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveTransaction,
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
            // ── Photo Thumbnail & AI Badge ────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.borderMd,
                    child: Image.file(
                      _imageFile!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedCategoryId != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: AppRadius.borderFull,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                                const Gap(6),
                                Text(
                                  'AI gợi ý: ${(suggestionConf * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(6),
                        ],
                        if (topLabel != null)
                          Text(
                            'Phát hiện: $topLabel',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Gap(4),
                        Text(
                          'Kiểm tra & chỉnh sửa trước khi lưu',
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

            // ── Optional Note and Merchant ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      labelText: 'Cửa hàng / Người nhận',
                      hintText: 'VD: Starbucks, Tiệm bánh...',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
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
