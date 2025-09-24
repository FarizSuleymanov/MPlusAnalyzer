import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';

class PrintPreview extends StatefulWidget {
  const PrintPreview(this.pdf, {super.key});
  final Uint8List pdf;
  @override
  State<PrintPreview> createState() => _PrintPreviewState();
}

class _PrintPreviewState extends State<PrintPreview> {
  TextEditingController txtCopies = TextEditingController();
  int _counter = 1;
  @override
  void initState() {
    txtCopies.text = '1';
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // Increment the counter variable
      _counter++;
      txtCopies.text = _counter.toString();
    });
  }

  // Function to decrement the counter
  // We add a check to prevent the counter from going below 0
  void _decrementCounter() {
    setState(() {
      if (_counter > 1) {
        _counter--;
        txtCopies.text = _counter.toString();
      }
    });
  }

  Widget getWidgetNumberOfCopy() {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: txtCopies,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent, width: 0),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  filled: true,
                  fillColor: Colors.white70,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Horizontally center the buttons
                children: <Widget>[
                  Expanded(
                    child: IconButton(
                      onPressed: _incrementCounter,
                      icon: Icon(Icons.arrow_drop_up),
                      padding: const EdgeInsets.all(
                        0,
                      ), // No extra padding by default
                      splashRadius: 30,
                    ),
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: _decrementCounter,
                      icon: Icon(Icons.arrow_drop_down),
                      padding: const EdgeInsets.all(
                        0,
                      ), // No extra padding by default
                      splashRadius: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ön İzləmə'),
        // actions: [
        //   SizedBox(child: Text('Çap sayı:', style: TextStyle(fontSize: 16))),
        //   getWidgetNumberOfCopy(),
        //   SizedBox(width: 17),
        //   IconButton(
        //     icon: const Icon(Icons.print),
        //     tooltip: 'Çap et',
        //     onPressed: () async {
        //       try {
        //         int copies = int.tryParse(txtCopies.text) ?? 1;
        //
        //         if (kIsWeb) {
        //           for (int i = 0; i < copies; i++) {
        //             await Printing.layoutPdf(
        //               onLayout: (PdfPageFormat format) async => widget.pdf,
        //             );
        //           }
        //         } else {
        //           List<Printer> listPrinters = await Printing.listPrinters();
        //           Printer defaultPrinter = listPrinters
        //               .where((p) => p.isDefault == true)
        //               .first;
        //           for (int i = 0; i < copies; i++) {
        //             await Printing.directPrintPdf(
        //               printer: defaultPrinter,
        //               onLayout: (PdfPageFormat format) async => widget.pdf,
        //             );
        //           }
        //         }
        //       } catch (e) {
        //         e.toString();
        //       }
        //     },
        //   ),
        //   SizedBox(width: 20),
        //   IconButton(
        //     icon: const Icon(Icons.close),
        //     tooltip: 'Bağla',
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: PdfPreview(
            useActions: true,
            allowPrinting: true,
            padding: EdgeInsets.all(5),
            canChangeOrientation: false,
            canChangePageFormat: false,
            shouldRepaint: false,
            allowSharing: true,
            canDebug: false,
            previewPageMargin: EdgeInsets.all(5),
            build: (format) => widget.pdf,
          ),
        ),
      ),
    );
  }
}
