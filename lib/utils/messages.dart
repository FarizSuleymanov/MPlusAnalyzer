import 'package:flutter/material.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';

class Messages {
  late BuildContext context;
  Messages({required this.context});

  LanguagePack languagePack = LanguagePack();

  showSnackBar(String message, int status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: status == 0 ? Colors.red : Colors.green,
        content: Center(
          child: Text(message, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Future<void> showWarningDialog(String message) async {
    String header = languagePack.getTranslatedText('warning');
    String done = languagePack.getTranslatedText('ok');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(children: [Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                done,
                style: TextStyle(color: ThemeModule.cBlackWhiteColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showYesNoDialog(
    String message,
    void Function() onPressedYes,
  ) async {
    String header = languagePack.getTranslatedText('attention');
    String yes = languagePack.getTranslatedText('yes');
    String no = languagePack.getTranslatedText('no');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(children: [Text(message)]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                no,
                style: TextStyle(color: ThemeModule.cBlackWhiteColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                yes,
                style: TextStyle(color: ThemeModule.cBlackWhiteColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                onPressedYes();
              },
            ),
          ],
        );
      },
    );
  }
}
