import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'calculateAnswerLogic.dart';

// マスのサイズを一括管理（ここを変えると全体の大きさが変わります）
const double baseCellSize = 48.0;

String _pdfLabelFor(AxisItem item) {
  final op = item.operator
      .replaceAll('×', 'x')
      .replaceAll('÷', '÷')
      .replaceAll('^', '^');
  return '$op${item.number}';
}

double _axisFontSizeFor(String label, double cellSize) {
  final baseSize = min(14.0, max(8.0, cellSize * 0.34));
  final length = max(1, label.length);
  final shrinkRatio = (3.0 / length).clamp(0.62, 1.12);
  return (baseSize * shrinkRatio).clamp(7.0, 15.0);
}

// 共通のセル構築ロジック（高さを固定して正方形を担保）
pw.Widget _buildSquareCell({
  required String text,
  required PdfColor color,
  required double cellSize,
  double? fontSize,
  bool isBold = false,
}) {
  final textSize = fontSize ?? min(14.0, max(8.0, cellSize * 0.34));

  return pw.Container(
    width: cellSize,
    height: cellSize, // ここで高さを固定
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      color: color,
      border: pw.Border.all(color: PdfColors.grey600, width: 0.7),
    ),
    child: pw.Text(
      text,
      maxLines: 1,
      style: pw.TextStyle(
        fontSize: textSize,
        fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

Future<void> printGridAsPdf({
  required String mode,
  required List<AxisItem> rowNumbers,
  required List<AxisItem> colNumbers,
}) async {
  try {
    final font = await PdfGoogleFonts.notoSansJPRegular();
    final fontBold = await PdfGoogleFonts.notoSansJPBold();

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) {
          return pw.LayoutBuilder(
            builder: (context, constraints) {
              const titleHeightBudget = 56.0;
              final maxCellByWidth = constraints!.maxWidth / 11;
              final maxCellByHeight =
                  (constraints.maxHeight - titleHeightBudget) / 11;
              final cellSize = min(
                baseCellSize,
                min(maxCellByWidth, maxCellByHeight),
              ).clamp(20.0, baseCellSize);

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // pw.Text(
                  //   '100マス計算練習 - $mode',
                  //   style: pw.TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: pw.FontWeight.bold,
                  //   ),
                  // ),
                  pw.SizedBox(height: 12),
                  pw.Table(
                    columnWidths: {
                      for (int i = 0; i <= 10; i++)
                        i: pw.FixedColumnWidth(cellSize),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          _buildSquareCell(
                            text: '',
                            color: PdfColors.white,
                            cellSize: cellSize,
                          ),
                          for (final rowItem in rowNumbers)
                            () {
                              final label = _pdfLabelFor(rowItem);
                              return _buildSquareCell(
                                text: label,
                                color: PdfColors.blue50,
                                cellSize: cellSize,
                                fontSize: _axisFontSizeFor(label, cellSize),
                                isBold: true,
                              );
                            }(),
                        ],
                      ),
                      for (int r = 0; r < 10; r++)
                        pw.TableRow(
                          children: [
                            () {
                              final label = _pdfLabelFor(colNumbers[r]);
                              return _buildSquareCell(
                                text: label,
                                color: PdfColors.orange50,
                                cellSize: cellSize,
                                fontSize: _axisFontSizeFor(label, cellSize),
                                isBold: true,
                              );
                            }(),
                            for (int c = 0; c < 10; c++)
                              _buildSquareCell(
                                text: '',
                                color: PdfColors.white,
                                cellSize: cellSize,
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '100grid_$mode.pdf',
    );
  } catch (e) {
    print("PDF印刷エラー: $e");
  }
}
