import 'dart:io';
import 'dart:math' as math;

import 'package:bill_tracker/core/extensions/format_extensions.dart';
import 'package:bill_tracker/features/reports/domain/entities/report_data.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

/// Renders a [ReportSummary] into a PDF using direct canvas drawing.
///
/// Intentionally simple ("đơn giản hóa so với UI"): stats block, donut
/// chart of category spendings, top 5 expenses, 6-month trend bar chart.
class ReportPdfService {
  /// Creates [ReportPdfService].
  const ReportPdfService();

  static const double _margin = 24;
  static const double _titleY = 30;

  Future<Font?> _loadInterFont() async {
    try {
      const key = 'assets/fonts/report_inter.ttf';
      final bytes = await flutter_services.rootBundle.load(key);
      return Font.ttf(bytes);
    } on Object {
      return null;
    }
  }

  String _labelMonth(DateTime month) =>
      'Tháng ${DateFormat('MM/yyyy').format(month)}';

  /// Exports the report for `summary.month` and returns the PDF file path.
  Future<String> exportAsPdf({required ReportSummary summary}) async {
    final font = await _loadInterFont();
    final fontBold = font ?? Font.helveticaBold();

    final pdf = Document()
      ..addPage(
        Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final canvas = context.canvas;
          final bold = fontBold.getFont(context);
          canvas.setColor(const PdfColor(0.13, 0.22, 0.31));
          _drawHeader(canvas, summary, bold);
          final statsY = _drawStats(
            canvas,
            summary,
            _titleY + 24,
            bold,
            context,
          );
          _drawDonut(canvas, summary, statsY + 12, context, font);
          final topY = _drawTopExpenses(
            canvas,
            summary,
            statsY + 12,
            bold,
            context,
          );
          _drawTrends(canvas, summary, topY + 12, context);
          return Container();
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName =
        'bill_tracker_report_${_labelMonth(summary.month).replaceAll('/', '_')}_$ts.pdf';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file.path;
  }

  void _drawHeader(
    PdfGraphics canvas,
    ReportSummary summary,
    PdfFont bold,
  ) {
    canvas.drawString(bold, 18, _labelMonth(summary.month), _margin, _titleY);
  }

  double _drawStats(
    PdfGraphics canvas,
    ReportSummary summary,
    double y,
    PdfFont bold,
    Context context,
  ) {
    final normal = Font.helvetica().getFont(context);

    void drawLine(String label, String value, double cx) {
      canvas
        ..drawString(bold, 8, label, cx, y)
        ..drawString(normal, 8, value, cx + 70, y);
    }

    drawLine('Tổng chi', summary.totalExpense.toVnd(), _margin);
    drawLine('Tổng thu', summary.totalIncome.toVnd(), _margin + 120);
    drawLine('Số dư', summary.netBalance.toVnd(), _margin + 240);
    final changePct = summary.expenseChangePercent.toStringAsFixed(1);
    drawLine(
      'Tháng trước',
      '${summary.expenseChangePercent >= 0 ? '+' : ''}$changePct%',
      _margin + 360,
    );
    return y + 16;
  }

  void _drawDonut(
    PdfGraphics canvas,
    ReportSummary summary,
    double y,
    Context context,
    Font? font,
  ) {
    final fontResolved = (font ?? Font.helvetica()).getFont(context);
    if (summary.categorySpendings.isEmpty) return;
    final cx = PdfPageFormat.a4.width / 2;
    final cy = y + 40;
    const r = 42.0;

    final total = summary.categorySpendings.fold<double>(
      0,
      (a, c) => a + c.amount,
    );
    if (total <= 0) return;

    // Background circle.
    canvas.setColor(const PdfColor(0.94, 0.94, 0.94));
    _fillCircle(canvas, cx, cy, r);

    var angle = -90.0;
    for (final c in summary.categorySpendings) {
      final sweep = 360 * (c.percentage / 100);
      final mid = angle + sweep / 2;
      final colorValue = c.category.colorValue;
      canvas
        ..setFillColor(
          PdfColor(
            ((colorValue >> 16) & 0xFF) / 255,
            ((colorValue >> 8) & 0xFF) / 255,
            (colorValue & 0xFF) / 255,
          ),
        )
        // Sector as polygon fan from center.
        ..moveTo(cx, cy);
      for (var a = angle; a <= angle + sweep; a += 6) {
        final rad = math.pi * a / 180;
        canvas.lineTo(cx + r * math.cos(rad), cy - r * math.sin(rad));
      }
      final rad = math.pi * mid / 180;
      canvas
        ..fillPath()
        ..setColor(const PdfColor(0.1, 0.1, 0.1))
        ..drawString(
          fontResolved,
          7.5,
          '${c.percentage.toStringAsFixed(1)}%',
          cx + (r * 0.45 * math.cos(rad)) - 15,
          cy - (r * 0.45 * math.sin(rad)),
        );
      angle += sweep;
    }
  }

  void _fillCircle(PdfGraphics canvas, double cx, double cy, double r) {
    canvas
      ..moveTo(cx + r, cy)
      ..setFillColor(const PdfColor(0.94, 0.94, 0.94));
    for (var a = 0; a < 360; a += 5) {
      final rad = math.pi * (a + 0.5) / 180;
      canvas.lineTo(cx + r * math.cos(rad), cy - r * math.sin(rad));
    }
    canvas.fillPath();
  }

  double _drawTopExpenses(
    PdfGraphics canvas,
    ReportSummary summary,
    double y,
    PdfFont bold,
    Context context,
  ) {
    if (summary.topExpenses.isEmpty) return y + 2;
    final normal = Font.helvetica().getFont(context);
    canvas.drawString(bold, 9, 'Top 5 giao dịch lớn nhất', _margin, y);
    var yy = y + 11;
    for (final t in summary.topExpenses.take(5)) {
      final name = t.merchant ?? t.category?.name ?? '';
      canvas
        ..drawString(normal, 8, name, _margin, yy)
        ..drawString(normal, 8, t.amount.toVnd(), _margin + 130, yy)
        ..drawString(
          normal,
          8,
          t.occurredAt.toDisplayDate(),
          _margin + 240,
          yy,
        );
      yy += 9;
    }
    return yy;
  }

  void _drawTrends(
    PdfGraphics canvas,
    ReportSummary summary,
    double y,
    Context context,
  ) {
    if (summary.monthlyTrends.isEmpty) return;
    canvas.drawString(
      Font.helveticaBold().getFont(context),
      9,
      'Xu hướng 6 tháng',
      _margin,
      y,
    );
    final trends = summary.monthlyTrends;
    const chartWidth = 430.0;
    const height = 70.0;
    final n = trends.length;
    final barW = chartWidth / n.toDouble();
    final maxExp = trends.fold<double>(
      0,
      (a, t) => a > t.expense ? a : t.expense,
    );

    for (var i = 0; i < n; i++) {
      final t = trends[i];
      final x = _margin + i * barW;
      final h1 = maxExp <= 0 ? 0.0 : t.expense / maxExp * height;
      if (h1 > 0) {
        canvas
          ..setColor(const PdfColor(0.13, 0.55, 0.35))
          ..drawRect(x, y + 12, barW, h1);
      }
      final h2 = maxExp <= 0 ? 0.0 : t.income / maxExp * height;
      if (h2 > 0) {
        canvas
          ..setColor(const PdfColor(0.58, 0.79, 0.57))
          ..drawRect(x, y + height - h2 + 12, barW, h2);
      }
      canvas
        ..setColor(const PdfColor(0.1, 0.1, 0.1))
        ..drawString(
          Font.helvetica().getFont(context),
          7,
          t.label,
          x + barW / 2 - 8,
          y + 2,
        );
    }
  }
}
