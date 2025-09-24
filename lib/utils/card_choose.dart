import 'package:flutter/material.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';

class CardChoose {
  late BuildContext context;
  CardChoose(this.context);

  LanguagePack lan = LanguagePack();

  Future<void> showCardModalBottomSheet(
    List<String> list,
    void Function(int) onLineTap,
  ) async {
    await showModalBottomSheet(
      backgroundColor: ThemeModule.cForeColor,
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).copyWith().size.height * 0.55,
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: ListView.separated(
          itemCount: list.length,
          itemBuilder: (contextM, index) => StatefulBuilder(
            builder: (context, _setState) => GestureDetector(
              onTap: () {
                onLineTap(index);
                Navigator.pop(context);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      list[index],
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'poppins_medium',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          separatorBuilder: (context, index) => SizedBox(height: 0),
        ),
      ),
    );
  }
}
