import 'package:flutter/services.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportConfront {
  ReportConfront();
  late pw.Font ttf, ttfBold;
  Future<Uint8List> getChequeDocument({
    required Map<String, dynamic> document_,
  }) async {
    double clientDebt = document_['clientDebt'].toDouble();
    double confrontedDebt = document_['confrontedDebt'].toDouble();
    String sellerFullName = document_['sellerFullName'];
    String clientAddress = document_['clientAddress'];
    String clientFullName = document_['clientFullName'];
    String chiefFullName = document_['chiefFullName'];
    String docDate = document_['docDate'];
    String companyName = GlobalParams.params.companyName;
    String chiefAccountant = GlobalParams.params.chiefAccountant;
    String assistantAccountant = GlobalParams.params.assistantAccountant;

    String day_ = docDate.substring(0, 2);
    String month_ = docDate.substring(3, 5);
    String year_ = docDate.substring(6, 10);

    final pdf = pw.Document();
    final fontReguler = await rootBundle.load("fonts/calibri-regular.ttf");
    final fontBold = await rootBundle.load("fonts/calibri-bold.ttf");
    ttf = pw.Font.ttf(fontReguler);
    ttfBold = pw.Font.ttf(fontBold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => getReport(
          day_,
          month_,
          year_,
          clientDebt,
          confrontedDebt,
          companyName,
          chiefAccountant,
          assistantAccountant,
          sellerFullName,
          clientAddress,
          clientFullName,
          chiefFullName,
        ),
      ),
    );

    final doc = await pdf.save();
    return doc;
  }

  pw.Widget getReport(
    String day_,
    String month_,
    String year_,
    double clientDebt,
    double confrontedDebt,
    String companyName,
    String chiefAccountant,
    String assistantAccountant,
    String sellerFullName,
    String clientAddress,
    String clientFullName,
    String chiefFullName,
  ) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(3),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 40),
          pw.Center(
            child: pw.Text(
              'ÜZLƏŞMƏ AKTI',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 18,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text(
                ' Bakı şəhəri',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.Text(
                getDateString(day_, month_, year_, ''),
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            '   Biz aşağıda izah edənlər $companyName-nin Baş mühasibi $chiefAccountant,',
            style: pw.TextStyle(font: ttf, fontSize: 11),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text(
                'Baş mühasibin müavini $assistantAccountant ,Satış müdiri ',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),

              pw.Expanded(child: getPersonalInfoUnderline(chiefFullName)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text('və ', style: pw.TextStyle(font: ttf, fontSize: 11)),
              pw.Expanded(child: getAddressIfoUnderline(clientAddress)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text(
                'ünvanda yerləşən ticarət obyektinin sahibi və ya səlahiyyətli nümayəndəsi ',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.Expanded(child: getPersonalInfoUnderline('')),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Expanded(child: getPersonalInfoUnderline(clientFullName)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            mainAxisSize: pw.MainAxisSize.max,
            children: [
              pw.Text(
                'ekspeditor',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
              pw.Expanded(child: getPersonalInfoUnderline(sellerFullName)),
              pw.Text(
                ' nin iştirakı ilə bu aktı tərtib',
                style: pw.TextStyle(font: ttf, fontSize: 11),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'edirik ondan ötürü ki, müştəri ilə müəssisə arasındakı mal qalığının məbləği aşağıdakı kimidir . Təsdiq olunmuş üzləşmə aktına görə bütün məsuliyyəti obyektin sahibi öz üzərinə götürür .',
            style: pw.TextStyle(font: ttf, fontSize: 11),
          ),
          pw.SizedBox(height: 10),
          getTable(day_, month_, year_, clientDebt, confrontedDebt),
          pw.SizedBox(height: 10),
          pw.Text(
            'Aktın doldurulmasını imzalarımızla təsdiq edirik:',
            style: pw.TextStyle(font: ttf, fontSize: 11),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '        İmzalar:',
            style: pw.TextStyle(font: ttf, fontSize: 11),
            textAlign: pw.TextAlign.start,
          ),
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(horizontal: 50),
            child: pw.Column(
              children: [
                getSignatureRow('1. Baş mühasib', chiefAccountant),
                getSignatureRow(
                  '2. Baş mühasibin müavini',
                  assistantAccountant,
                ),
                getSignatureRow('3. Satış müdiri', chiefFullName),
                getSignatureRow('4. Müştəri', clientFullName),
                getSignatureRow('5. Ekspeditor', sellerFullName),
                getSignatureRow('6.          ', ''),
              ],
            ),
          ),
        ],
      ),
    );
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

                style: pw.TextStyle(font: ttf, fontSize: 10),
              ),
            ],
          ),
        ),
        pw.Divider(height: 1),
        pw.Text(
          '(imza)                                                  (soyadı, adı, atasının adı) ',
          style: pw.TextStyle(font: ttf, fontSize: 7),
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

  pw.Widget getTable(
    String day_,
    String month_,
    String year_,
    double clientDebt,
    double confrontedDebt,
  ) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: pw.Table(
        border: pw.TableBorder.all(),
        columnWidths: const {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(1),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
        },

        children: [
          pw.TableRow(
            children: [
              _tableCell('Üzləşmə aktının təsdiqləndiyi tarix '),
              _tableCell('Hesabat üzrə müəssisəyə olan borc '),
              _tableCell('Müştəri tərəfindən təsdiq olunan '),
              _tableCell('Yaranan fərq (+) artıq (-) əksik '),
            ],
          ),
          pw.TableRow(
            children: [
              _tableCell('Valyuta'),
              _tableCell('azn '),
              _tableCell('azn '),
              _tableCell('azn '),
            ],
          ),
          pw.TableRow(
            children: [
              _tableCell(getDateString(day_, month_, year_, ' tarixinə')),
              _tableCell(clientDebt.toStringAsFixed(2)),
              _tableCell(confrontedDebt.toStringAsFixed(2)),
              _tableCell((clientDebt - confrontedDebt).toStringAsFixed(2)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(2.0),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: ttf, fontSize: 9),
      ),
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

  pw.Widget getSignatureRow(String label, String label2) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.SizedBox(
          width: 150,
          child: pw.Text(label, style: pw.TextStyle(font: ttf, fontSize: 11)),
        ),
        pw.SizedBox(
          width: 300,
          child: getPersonalInfoAndSignatureUnderline(label2),
        ),
      ],
    );
  }
}
