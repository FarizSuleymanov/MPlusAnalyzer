import 'package:flutter/services.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportCounting {
  late pw.Font ttf, ttfBold;
  Future<Uint8List> getChequeDocument({
    required dynamic row,
    required List countingLines,
  }) async {
    String docDate = row['cntDocDate'],
        seller = row['cntSeller'],
        chief = row['cntChief'];

    String companyName = GlobalParams.params.companyName;
    String chiefAccountant = GlobalParams.params.chiefAccountant;
    String assistantAccountant = GlobalParams.params.assistantAccountant;

    double tlOnCar = 0,
        tlOnCarSum = 0,
        tlTyped = 0,
        tlTypedSum = 0,
        tlDiffQuantity = 0,
        tlDiffSum = 0;

    countingLines.forEach((line) {
      double itemPrice = line['qntPrice'].toDouble() ?? 0.0;
      double qntOnCar = line['qntOnCar'].toDouble() ?? 0.0;
      double qntTyped1 = line['qntTyped1'].toDouble() ?? 0.0;
      double qntTyped2 = line['qntTyped2'].toDouble() ?? 0.0;
      double qntTyped3 = line['qntTyped3'].toDouble() ?? 0.0;
      double qntTyped4 = line['qntTyped4'].toDouble() ?? 0.0;
      double qntTyped5 = line['qntTyped5'].toDouble() ?? 0.0;
      tlOnCar += qntOnCar;
      tlTyped += qntTyped1 + qntTyped2 + qntTyped3 + qntTyped4 + qntTyped5;
      tlOnCarSum += itemPrice * qntOnCar;
      tlTypedSum +=
          itemPrice *
          (qntTyped1 + qntTyped2 + qntTyped3 + qntTyped4 + qntTyped5);
    });
    tlDiffQuantity = tlOnCar - tlTyped;
    tlDiffSum = tlOnCarSum - tlTypedSum;

    String day_ = docDate.substring(0, 2);
    String month_ = docDate.substring(3, 5);
    String year_ = docDate.substring(6, 10);

    final pdf = pw.Document();
    final fontReguler = await rootBundle.load("fonts/calibri-regular.ttf");
    final fontBold = await rootBundle.load("fonts/calibri-bold.ttf");
    ttf = pw.Font.ttf(fontReguler);
    ttfBold = pw.Font.ttf(fontBold);

    int pageCount = 0;
    int lineCount = countingLines.length;
    if (lineCount <= 25) {
      pageCount = 1;
    } else if (lineCount > 25 && lineCount <= 60) {
      pageCount = 2;
    } else if (lineCount > 60) {
      int added = 2;
      if (((lineCount - 45) / 60).remainder(1) < 2 / 3) {
        added = 1;
      }
      pageCount = ((lineCount - 60) / 60).ceil() + added;
    }

    for (int i = 0; i < pageCount; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(3),
              child: pw.Column(
                children: [
                  i == 0
                      ? getReportHeader(
                          day_,
                          month_,
                          year_,
                          companyName,
                          seller,
                        )
                      : pw.Container(),
                  getTableHeader(),
                  getTableRows(countingLines, i, pageCount),

                  i == pageCount - 1
                      ? getReportFooter(
                          day_,
                          month_,
                          year_,
                          chiefAccountant,
                          assistantAccountant,
                          seller,
                          chief,
                          countingLines,
                          tlOnCar,
                          tlOnCarSum,
                          tlTyped,
                          tlTypedSum,
                          tlDiffQuantity,
                          tlDiffSum,
                        )
                      : pw.Container(),
                ],
              ),
            );
          },
        ),
      );
    }

    final doc = await pdf.save();
    return doc;
  }

  pw.Widget getReportHeader(
    String day_,
    String month_,
    String year_,
    String companyName,
    String seller,
  ) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Əlavə № 2',
            style: pw.TextStyle(font: ttf, fontSize: 8),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Təsdiq edirəm:     ',
            style: pw.TextStyle(font: ttfBold, fontSize: 10),
          ),
        ),

        pw.Row(
          children: [
            pw.Expanded(flex: 3, child: pw.Container()),
            pw.Expanded(flex: 2, child: getSignatureRowHeader('Şöbə müdiri:')),
          ],
        ),

        pw.SizedBox(height: 5),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Tarix: ${getDateString(day_, month_, year_, '')}            ',
            style: pw.TextStyle(font: ttf, fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            '$companyName-nin ekspeditoru maddi məsul şəxs',
            style: pw.TextStyle(font: ttfBold, fontSize: 10),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            '$seller-nin servis anbarinda olan maddi qiymətlilərin',
            style: pw.TextStyle(font: ttfBold, fontSize: 10),
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            'inventarizasiya aktı',
            style: pw.TextStyle(font: ttfBold, fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          '           Biz aşağida  imza  edən komissiya üzvləri  bu aktı ona  görə tərtib  edirik ki,  həqiqətən də  ${getDateString(day_, month_, year_, '')}',
          style: pw.TextStyle(font: ttf, fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'tarixində  ekspeditor $seller-nın maddi  məsul şəxs olduğu servis anbarında faktiki mal qalığını araşdırmaq',
          style: pw.TextStyle(font: ttf, fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'məqsədi  ilə   inventarizasiya  apardıq   və   aşağıdakı  cədvəldə   göstərilmiş   miqdarda  və   məbləğdə  maddi  qiymətliləri  ',
          style: pw.TextStyle(font: ttf, fontSize: 10),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'komissiya üzvlərinin iştirakı ilə aşkar etdik.',
          style: pw.TextStyle(font: ttf, fontSize: 10),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget getReportFooter(
    String day_,
    String month_,
    String year_,
    String chiefAccountant,
    String assistantAccountant,
    String seller,
    String chief,
    List countingLines,
    double tlOnCar,
    double tlOnCarSum,
    double tlTyped,
    double tlTypedSum,
    double tlDiffQuantity,
    double tlDiffSum,
  ) {
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        getTableFooterRow(
          tlOnCar,
          tlOnCarSum,
          tlTyped,
          tlTypedSum,
          tlDiffQuantity,
          tlDiffSum,
        ),
        pw.SizedBox(height: 5),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: 'Beləliklə, faktiki olaraq  servis anbarında ',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
              pw.TextSpan(
                text: tlTyped.toStringAsFixed(2),
                style: pw.TextStyle(font: ttfBold, fontSize: 10),
              ),
              pw.TextSpan(
                text: ' kq  miqdarında, ',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
              pw.TextSpan(
                text: tlTypedSum.toStringAsFixed(2),
                style: pw.TextStyle(font: ttfBold, fontSize: 10),
              ),
              pw.TextSpan(
                text:
                    ' manat məbləğində mal qalığı aşkar edildi.Muhasibatlığın ',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 2),
        pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text:
                    'uçot sənədlərində isə ${getDateString(day_, month_, year_, '')} tarixində servis anbarında mal qalığı ',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),

              pw.TextSpan(
                text: tlOnCar.toStringAsFixed(2),
                style: pw.TextStyle(font: ttfBold, fontSize: 10),
              ),
              pw.TextSpan(
                text: ' kq miqdarında, ',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
              pw.TextSpan(
                text: tlOnCarSum.toStringAsFixed(2),
                style: pw.TextStyle(font: ttfBold, fontSize: 10),
              ),
              pw.TextSpan(
                text: ' manat məbləğində',
                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 2),
        getResultWidget(tlDiffQuantity, tlDiffSum),
        pw.SizedBox(height: 20),
        pw.Text(
          '   Aktın doldurulmasını imzalarımızla təsdiq edirik:',
          style: pw.TextStyle(font: ttf, fontSize: 8),
        ),
        pw.SizedBox(height: 10),
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(horizontal: 50),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Komissiyanın sədri :',
                style: pw.TextStyle(font: ttfBold, fontSize: 8),
              ),

              getSignatureRow('Baş mühasib:', chiefAccountant),
              pw.Text(
                'Komissiyanın üzvləri :',
                style: pw.TextStyle(font: ttfBold, fontSize: 9),
              ),

              getSignatureRow('Baş mühasibin müavini', assistantAccountant),
              getSignatureRow('Mühasib', ''),
              getSignatureRow('Satış müdiri', chief),
              pw.Text(
                'İnventarizasiya aktının nəticələrini :',
                style: pw.TextStyle(font: ttfBold, fontSize: 9),
              ),
              pw.Text(
                '       Təsdiq Edirəm :',
                style: pw.TextStyle(font: ttf, fontSize: 9),
              ),
              getSignatureRow(
                '        Maddi məsul şəxs (ekspeditor):  ',
                seller,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget getResultWidget(double tlDiffQuantity, double tlDiffSum) {
    if (tlDiffQuantity == 0) {
      return pw.Text(
        'olduğundan servis anbarında malın artığ və ya artığ gəlmə halı aşkar edilməmişdir.',
        style: pw.TextStyle(font: ttf, fontSize: 9),
      );
    } else {
      return pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: 'olduğundan servis anbarında ',
              style: pw.TextStyle(font: ttf, fontSize: 10),
            ),
            pw.TextSpan(
              text: tlDiffQuantity.toStringAsFixed(2),
              style: pw.TextStyle(font: ttfBold, fontSize: 10),
            ),
            pw.TextSpan(
              text: ' kg miqdarında, ',
              style: pw.TextStyle(font: ttf, fontSize: 10),
            ),
            pw.TextSpan(
              text: tlDiffSum.toStringAsFixed(2),
              style: pw.TextStyle(font: ttfBold, fontSize: 10),
            ),
            pw.TextSpan(
              text:
                  ' manat məbləğində ${tlDiffQuantity > 0 ? 'artıq' : 'əksik'} gəlmə halı aşkarlanmışdır.',
              style: pw.TextStyle(font: ttf, fontSize: 10),
            ),
          ],
        ),
      );
    }
  }

  String getMonthString(String month_) {
    switch (month_) {
      case '01':
        return 'Yanvar';
      case '02':
        return 'Fevral';
      case '03':
        return 'Mart';
      case '04':
        return 'Aprel';
      case '05':
        return 'May';
      case '06':
        return 'İyun';
      case '07':
        return 'İyul';
      case '08':
        return 'Avqust';
      case '09':
        return 'Sentyabr';
      case '10':
        return 'Oktyabr';
      case '11':
        return 'Noyabr';
      case '12':
        return 'Dekabr';
      default:
        return '';
    }
  }

  String getArticleForYear(String year_) {
    String lastNumberOfYear = year_.substring(year_.length - 1);
    switch (lastNumberOfYear) {
      case '1':
      case '2':
      case '5':
      case '7':
      case '8':
        return '-ci';
      case '3':
      case '4':
        return '-cü';
      case '6':
        return '-cı';
      case '9':
      case '0':
        return '-cu';
      default:
        return '';
    }
  }

  pw.Widget getPersonalInfoUnderline(String label) {
    return pw.Column(
      children: [
        label == ''
            ? pw.SizedBox(height: 20)
            : pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.Divider(height: 1),
        pw.Text(
          '(soyadı, adı, atasının adı) ',
          style: pw.TextStyle(font: ttf, fontSize: 7),
        ),
      ],
    );
  }

  pw.Widget getPersonalInfoAndSignatureUnderline(String label) {
    return pw.Column(
      children: [
        pw.SizedBox(
          height: 20,
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                '                               $label',

                style: pw.TextStyle(font: ttf, fontSize: 8),
              ),
            ],
          ),
        ),
        pw.Divider(height: 1),
        pw.Text(
          '(imza)                                                  (soyadı, adı, atasının adı) ',
          style: pw.TextStyle(font: ttf, fontSize: 6),
        ),
      ],
    );
  }

  pw.Widget getPersonalInfoAndSignaturUenderlineHeader() {
    return pw.Column(
      children: [
        pw.SizedBox(height: 18),
        pw.Divider(height: 1),
        pw.Text(
          '(imza)           (soyadı, adı, atasının adı) ',
          style: pw.TextStyle(font: ttf, fontSize: 6),
        ),
      ],
    );
  }

  pw.Widget getAddressIfoUnderline(String label) {
    return pw.Column(
      children: [
        label == ''
            ? pw.SizedBox(height: 20)
            : pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 11)),
        pw.Divider(height: 1),
        pw.Text('(ünvan) ', style: pw.TextStyle(font: ttf, fontSize: 7)),
      ],
    );
  }

  pw.Widget getSignatureRow(String label, String label2) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 8)),
        ),
        pw.SizedBox(
          width: 300,
          child: getPersonalInfoAndSignatureUnderline(label2),
        ),
      ],
    );
  }

  pw.Widget getSignatureRowHeader(String label) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 10)),
        pw.SizedBox(
          width: 150,
          child: getPersonalInfoAndSignaturUenderlineHeader(),
        ),
      ],
    );
  }

  pw.BoxDecoration getTableDecoration() {
    return pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black, width: 0.5),
    );
  }

  pw.Widget getHeaderText(String text, int height) {
    return pw.Container(
      height: height.toDouble(),
      decoration: getTableDecoration(),
      child: pw.Align(
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: ttfBold, fontSize: 8),
        ),
      ),
    );
  }

  pw.Widget getRowIntText(String text, pw.Font ttf_) {
    return pw.Container(
      decoration: getTableDecoration(),
      child: pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(font: ttf_, fontSize: 8),
        ),
      ),
    );
  }

  pw.Widget getRowStrText(String text, pw.Font ttf_) {
    return pw.Container(
      decoration: getTableDecoration(),

      child: pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(font: ttf_, fontSize: 8),
        ),
      ),
    );
  }

  pw.Widget getTableHeaderColumn(String text) {
    return pw.Expanded(
      flex: 10,
      child: pw.Container(
        decoration: getTableDecoration(),
        child: pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [pw.Expanded(flex: 1, child: getHeaderText(text, 15))],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(flex: 1, child: getHeaderText('miqdar', 10)),
                pw.Expanded(flex: 1, child: getHeaderText('məbləğ', 10)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(flex: 1, child: getHeaderText('kg', 10)),
                pw.Expanded(flex: 1, child: getHeaderText('azn', 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget getTableHeader() {
    return pw.Container(
      decoration: getTableDecoration(),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(flex: 2, child: getHeaderText('№', 35)),
          pw.Expanded(flex: 16, child: getHeaderText('Malların adı', 35)),
          getTableHeaderColumn('Mühasibat uçotu üzrə'),
          getTableHeaderColumn('Faktiki olaraq'),
          getTableHeaderColumn('artıq(+) əksik(-) gəlmə'),
        ],
      ),
    );
  }

  pw.Widget getTableRows(List countingLines, int pageIndex, int pageCount) {
    List listLines = [];
    int countLinesOfFirstPage = 0;
    if (pageCount == 1) {
      countLinesOfFirstPage = 25;
    } else {
      countLinesOfFirstPage = 45;
    }
    int lineNumberStartWith = 0;

    if (pageIndex == 0) {
      listLines = countingLines.take(countLinesOfFirstPage).toList();
    } else {
      listLines = countingLines
          .skip(countLinesOfFirstPage + ((pageIndex - 1) * 60))
          .take(60)
          .toList();
      lineNumberStartWith = countLinesOfFirstPage + ((pageIndex - 1) * 60);
    }

    return pw.ListView.builder(
      itemBuilder: (context, index) =>
          getTableRow(listLines[index], lineNumberStartWith + index),
      itemCount: listLines.length,
    );
  }

  pw.Widget getTableRow(dynamic line, int index) {
    double qntPrice = line['qntPrice'].toDouble() ?? 0.0;
    double qntOnCar = line['qntOnCar'].toDouble() ?? 0.0;
    double qntTyped1 = line['qntTyped1'].toDouble() ?? 0.0;
    double qntTyped2 = line['qntTyped2'].toDouble() ?? 0.0;
    double qntTyped3 = line['qntTyped3'].toDouble() ?? 0.0;
    double qntTyped4 = line['qntTyped4'].toDouble() ?? 0.0;
    double qntTyped5 = line['qntTyped5'].toDouble() ?? 0.0;
    double qntTypedToTal =
        qntTyped1 + qntTyped2 + qntTyped3 + qntTyped4 + qntTyped5;
    double qntDifirence = qntOnCar - qntTypedToTal;
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(flex: 2, child: getRowStrText((index + 1).toString(), ttf)),
        pw.Expanded(flex: 16, child: getRowStrText(line['itemName'], ttf)),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(qntOnCar.toStringAsFixed(2), ttf),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText((qntOnCar * qntPrice).toStringAsFixed(2), ttf),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(qntTypedToTal.toStringAsFixed(2), ttf),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(
            (qntTypedToTal * qntPrice).toStringAsFixed(2),
            ttf,
          ),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(qntDifirence.toStringAsFixed(2), ttf),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(
            (qntDifirence * qntPrice).toStringAsFixed(2),
            ttf,
          ),
        ),
      ],
    );
  }

  pw.Widget getTableFooterRow(
    double tlOnCar,
    double tlOnCarSum,
    double tlTyped,
    double tlTypedSum,
    double tlDiffQuantity,
    double tlDiffSum,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(flex: 18, child: getRowStrText('CƏMİ', ttfBold)),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(tlOnCar.toStringAsFixed(2) + ' kg', ttfBold),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(tlOnCarSum.toStringAsFixed(2) + ' azn', ttfBold),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(tlTyped.toStringAsFixed(2) + ' kg', ttfBold),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(tlTypedSum.toStringAsFixed(2) + ' azn', ttfBold),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(
            tlDiffQuantity.toStringAsFixed(2) + ' kg',
            ttfBold,
          ),
        ),
        pw.Expanded(
          flex: 5,
          child: getRowIntText(tlDiffSum.toStringAsFixed(2) + ' azn', ttfBold),
        ),
      ],
    );
  }

  String getDateString(
    String day_,
    String month_,
    String year_,
    String addition,
  ) {
    return '"$day_" ${getMonthString(month_)} $year_${getArticleForYear(year_)} il $addition';
  }
}
