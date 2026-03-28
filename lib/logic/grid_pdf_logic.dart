import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'calculateAnswerLogic.dart';

String _pdfLabelFor(AxisItem item) {
  final op = item.operator
      .replaceAll('×', 'x')
      .replaceAll('÷', '÷')
      .replaceAll('^', '^');
  return '$op${item.number}';
}

pw.Widget _axisCell(String text, PdfColor color) {
  return pw.Container(
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.all(4),
    decoration: pw.BoxDecoration(
      color: color,
      border: pw.Border.all(color: PdfColors.grey600, width: 0.7),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
    ),
  );
}

pw.Widget _blankCell() {
  return pw.Container(
    height: 22,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey600, width: 0.7),
    ),
    child: pw.Text('', style: const pw.TextStyle(fontSize: 10)),
  );
}

Future<void> printGridAsPdf({
  required String mode,
  required List<AxisItem> rowNumbers,
  required List<AxisItem> colNumbers,
}) async {
  print("🖨️ 印刷処理をスタートします...");

  try {
    // ここで時間がかかっている、もしくはエラーで落ちている可能性が高いです
    print("⏳ フォントをダウンロード中（初回は数秒かかります）...");
    final font = await PdfGoogleFonts.notoSansJPRegular();
    final fontBold = await PdfGoogleFonts.notoSansJPBold();
    print("✅ フォントの取得に成功しました！PDFのレイアウトを構築します...");

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '100 Grid Practice - $mode',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey600,
                  width: 0.7,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.1),
                  for (int i = 1; i <= 10; i++) i: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      _axisCell('', PdfColors.grey200),
                      for (final rowItem in rowNumbers)
                        _axisCell(_pdfLabelFor(rowItem), PdfColors.lightBlue50),
                    ],
                  ),
                  for (int r = 0; r < 10; r++)
                    pw.TableRow(
                      children: [
                        _axisCell(
                          _pdfLabelFor(colNumbers[r]),
                          PdfColors.orange50,
                        ),
                        for (int c = 0; c < 10; c++) _blankCell(),
                      ],
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );

    print("🚀 プリントダイアログ（プレビュー）を呼び出します...");
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
      name: '100_grid_practice.pdf', // 保存時のデフォルトファイル名
    );
    print("🎉 印刷処理が正常に完了しました！");
  } catch (e, stackTrace) {
    // どこかでエラーが起きたらここに出力されます
    print("🚨 印刷処理中にエラーが発生しました: $e");
    print(stackTrace);
  }
}
