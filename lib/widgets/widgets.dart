import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mplusanalyzer/models/client_extra_lines.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/auto_sliding_text.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class Widgets {
  LanguagePack lan = LanguagePack();
  Widget getTextFormField(
    TextEditingController controller,
    void Function(String newValue) onFieldSubmitted,
    List<TextInputFormatter> inputFormatters,
    String labelText,
    Color labelColor,
    Color fillColor,
    bool isObscureText,
    TextInputType textInputType,
  ) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      obscureText: isObscureText,
      keyboardType: textInputType,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: labelColor),
        labelText: lan.getTranslatedText(labelText),
        hintText: lan.getTranslatedText(labelText),
      ),
      onFieldSubmitted: (value) {
        onFieldSubmitted(value);
      },
    );
  }

  Widget getSearchBar(
    BuildContext context,
    TextEditingController txtSearchController,
    void Function() onFieldSubmitted,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: txtSearchController,
        inputFormatters: [LengthLimitingTextInputFormatter(25)],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: lan.getTranslatedText('search'),
          hintStyle: TextStyle(color: ThemeModule.cWhiteBlackColor),
        ),
        style: TextStyle(
          color: ThemeModule.cWhiteBlackColor,
          decorationThickness: 0,
        ),
        autofocus: true,
        onFieldSubmitted: (_) => onFieldSubmitted(),
      ),
    );
  }

  Widget getTextFormFieldForPassword(
    TextEditingController controller,
    void Function(String newValue) onFieldSubmitted,
    List<TextInputFormatter> inputFormatters,
    String labelText,
    Color labelColor,
    Color fillColor,
    bool isObscureText,
    void Function() onVisibilityIconTap,
  ) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      obscureText: isObscureText,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: fillColor,
        labelStyle: TextStyle(color: labelColor),
        labelText: labelText,
        hintText: labelText,
        suffixIcon: IconButton(
          icon: Icon(isObscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () => onVisibilityIconTap(),
        ),
      ),
      onFieldSubmitted: (value) {
        onFieldSubmitted(value);
      },
    );
  }

  Widget getRichText(
    String headerText,
    TextStyle headerStyle,
    String valueText,
    TextStyle valueStyle,
  ) {
    return Row(
      children: [
        Text('$headerText: ', style: headerStyle),
        Expanded(
          child: AutoSlidingText(
            text: valueText,
            style: valueStyle,
            duration: const Duration(seconds: 4),
            direction: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget getEmptyDataWidget() {
    return Center(child: Image.asset('assets/icons/empty.png'));
  }

  Widget getErrorWidget() {
    return Center(child: Image.asset('assets/icons/empty.png'));
  }

  Widget getInvoiceCheckBoxWidget(
    BuildContext context,
    bool value,
    String key,
    bool enabled,
    IconData icon,
    void Function(bool) onValueChanged,
  ) {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: CheckboxListTile(
          enabled: enabled,
          contentPadding: EdgeInsets.all(0),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxHeight: 22),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  lan.getTranslatedText(key),
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 18, fontFamily: 'poppins_medium'),
                ),
              ),
            ),
          ),
          value: value,
          secondary: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/icon_background.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Icon(size: 30, icon, color: ThemeModule.cWhiteBlackColor),
            ),
          ),
          onChanged: (v) => onValueChanged(v!),
        ),
      ),
    );
  }

  Widget getInvoiceChooseCardWidget(
    BuildContext context,
    String elName,
    String elKey,
    String elChooseKey,
    IconData icon,
    bool isChosen,
    void Function() onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Card(
        margin: EdgeInsets.all(2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: !isChosen
            ? ListTile(
                contentPadding: EdgeInsets.all(4),
                minTileHeight: 50.0,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/icon_background.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        size: 30,
                        icon,
                        color: ThemeModule.cWhiteBlackColor,
                      ),
                    ),
                  ),
                ),
                title: Text(lan.getTranslatedText(elChooseKey)),
                trailing: Icon(Icons.keyboard_arrow_right),
              )
            : ListTile(
                contentPadding: EdgeInsets.all(2),
                minTileHeight: 50.0,
                leading: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/icon_background.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        size: 30,
                        icon,
                        color: ThemeModule.cWhiteBlackColor,
                      ),
                    ),
                  ),
                ),
                title: AutoSlidingText(
                  text: elName,
                  style: TextStyle(fontSize: 16, fontFamily: 'poppins_medium'),
                  duration: const Duration(seconds: 4),
                  direction: Axis.horizontal,
                ),
                subtitle: Text(
                  lan.getTranslatedText(elKey),
                  style: TextStyle(fontSize: 10, fontFamily: 'poppins_regular'),
                ),
              ),
      ), // PriceType
    );
  }

  Widget getInvoiceTextFieldWidget(
    BuildContext context,
    TextEditingController controller,
    String labelTextKey,
    IconData icon,
    void Function(String) onFieldSubmitted,
    List<TextInputFormatter> inputFormatters, {
    TextInputType textInputType = TextInputType.text,
  }) {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
        child: TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffDADADA), width: 0),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            filled: true,
            fillColor: Colors.transparent,
            icon: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/icons/icon_background.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Icon(
                    size: 30,
                    icon,
                    color: ThemeModule.cWhiteBlackColor,
                  ),
                ),
              ),
            ),
            labelText: lan.getTranslatedText(labelTextKey),
            hintText: lan.getTranslatedText(labelTextKey),
            floatingLabelStyle: TextStyle(color: Colors.black),
          ),
          onFieldSubmitted: (v) => onFieldSubmitted(v),
          onChanged: (v) => onFieldSubmitted(v),
          keyboardType: textInputType,
        ),
      ),
    );
  }

  Widget getInvoiceTextWidget(
    BuildContext context,
    String elName,
    String elKey,
    IconData icon,
  ) {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(2),
        minTileHeight: 50.0,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/icon_background.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Center(
              child: Icon(size: 30, icon, color: ThemeModule.cWhiteBlackColor),
            ),
          ),
        ),
        title: AutoSlidingText(
          text: elName,
          style: TextStyle(fontSize: 16, fontFamily: 'poppins_medium'),
          duration: const Duration(seconds: 4),
          direction: Axis.horizontal,
        ),
        subtitle: Text(
          lan.getTranslatedText(elKey),
          style: TextStyle(fontSize: 10, fontFamily: 'poppins_regular'),
        ),
      ),
    );
  }

  Widget getLoadingWidget(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: ThemeModule.cForeColor),
    );
  }

  Widget getLoadingWidgetWithInfo(
    BuildContext context, {
    bool? isAnErrorOccurred,
    String? labelKey,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          top: 30,
          bottom: 250,
        ),
        child: Card(
          child: SizedBox(
            height: 140,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isAnErrorOccurred != null && isAnErrorOccurred
                      ? Icon(
                          Icons.error_outline_sharp,
                          color: Colors.red,
                          size: 50,
                        )
                      : CircularProgressIndicator(
                          color: ThemeModule.cForeColor,
                        ),
                  SizedBox(height: 10),
                  labelKey != null
                      ? Text(
                          lan.getTranslatedText(labelKey),
                          style: TextStyle(fontSize: 18),
                        )
                      : Container(),
                  isAnErrorOccurred != null && isAnErrorOccurred
                      ? Text(
                          lan.getTranslatedText('tryAgain'),
                          style: TextStyle(fontSize: 16),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getFloatingButton(
    BuildContext context,
    String key,
    IconData icon,
    void Function() onTap,
  ) {
    return FloatingActionButton.extended(
      onPressed: () => onTap(),
      label: Text(
        lan.getTranslatedText(key),
        style: TextStyle(color: ThemeModule.cWhiteBlackColor, fontSize: 17),
      ),
      icon: Icon(icon, size: 30, color: ThemeModule.cWhiteBlackColor),
      heroTag: key,
    );
  }

  Widget getTextFormFieldForDate(
    BuildContext context,
    TextEditingController controller,
    void Function() onTap,
    String labelText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: false,
      readOnly: true,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ThemeModule.cForeColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ThemeModule.cForeColor, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        prefixIcon: Icon(Icons.calendar_month),
        filled: true,
        fillColor: Colors.white.withAlpha(200),
        labelText: lan.getTranslatedText(labelText),
      ),
      onTap: () {
        onTap();
      },
    );
  }

  Widget getSlideElement(
    String labelKey,
    IconData icon,
    void Function() onTap,
    Color color,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(),
        child: Card(
          margin: EdgeInsets.all(2),
          color: color,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 30),
                  SizedBox(height: 5),
                  Text(
                    lan.getTranslatedText(labelKey),
                    style: TextStyle(fontFamily: 'poppins_bold'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getInvoiceMultiSelectWidget(
    BuildContext context,
    MultiSelectController<int> controller,
    String elKey,
    String label,
    IconData icon,
    List<DropdownItem<int>> items,
  ) {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/icon_background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      size: 30,
                      icon,
                      color: ThemeModule.cWhiteBlackColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MultiDropdown<int>(
                  items: items,
                  controller: controller,
                  enabled: true,
                  chipDecoration: ChipDecoration(
                    backgroundColor: ThemeModule.cForeColor,
                    labelStyle: TextStyle(color: ThemeModule.cWhiteBlackColor),
                    wrap: true,
                    runSpacing: 2,
                    spacing: 10,
                    deleteIcon: Icon(null),
                  ),
                  fieldDecoration: FieldDecoration(
                    labelText: lan.getTranslatedText(elKey),
                    hintText: lan.getTranslatedText(elKey),
                    hintStyle: const TextStyle(color: Colors.black87),
                    showClearIcon: false,
                    border: InputBorder.none,
                  ),
                  dropdownDecoration: DropdownDecoration(
                    marginTop: 2,
                    maxHeight: 500,
                  ),
                  dropdownItemDecoration: DropdownItemDecoration(
                    selectedIcon: Icon(
                      Icons.check_box,
                      color: ThemeModule.cForeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget getInvoiceMultiSelectWidgetString(
    BuildContext context,
    String elKey,
    String label,
    IconData icon,
    List<DropdownItem<String>> items,
    void Function(List<String>) onSelectionChange,
  ) {
    return Card(
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/icons/icon_background.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      size: 30,
                      icon,
                      color: ThemeModule.cWhiteBlackColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MultiDropdown<String>(
                  key: ValueKey(items.hashCode),
                  items: items,
                  enabled: true,
                  chipDecoration: ChipDecoration(
                    backgroundColor: ThemeModule.cForeColor,
                    labelStyle: TextStyle(color: ThemeModule.cWhiteBlackColor),
                    wrap: true,
                    runSpacing: 2,
                    spacing: 10,
                    deleteIcon: Icon(null),
                  ),
                  fieldDecoration: FieldDecoration(
                    labelText: lan.getTranslatedText(elKey),
                    hintText: lan.getTranslatedText(elKey),
                    hintStyle: const TextStyle(color: Colors.black87),
                    showClearIcon: false,
                    border: InputBorder.none,
                  ),
                  dropdownDecoration: DropdownDecoration(
                    marginTop: 2,
                    maxHeight: 500,
                  ),
                  dropdownItemDecoration: DropdownItemDecoration(
                    selectedIcon: Icon(
                      Icons.check_box,
                      color: ThemeModule.cForeColor,
                    ),
                  ),
                  onSelectionChange: onSelectionChange,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget getWidgetItemCard(
    BuildContext context,
    ClientExtraLines item,
    String clientCode,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      height: 68,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: Offset(2, 4), // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(22),
        color: ThemeModule.cWhiteBlackColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              item.itemName,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: 'poppins_semibold',
                fontSize: 12,
                color: ThemeModule.cBlackWhiteColor,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 37,
                child: Widgets().getRichText(
                  lan.getTranslatedText('code'),
                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontFamily: 'poppins_regular',
                    fontSize: 12,
                  ),
                  item.itemCode,
                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontSize: 12,
                    fontFamily: 'poppins_semibold',
                  ),
                ),
              ),
              Expanded(
                flex: 33,
                child: Widgets().getRichText(
                  lan.getTranslatedText('price'),
                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontFamily: 'poppins_regular',
                    fontSize: 12,
                  ),
                  item.price.toStringAsFixed(2) + '₼',
                  TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'poppins_semibold',
                  ),
                ),
              ),
              Expanded(
                flex: 30,
                child: Widgets().getRichText(
                  lan.getTranslatedText('total'),
                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontFamily: 'poppins_regular',
                    fontSize: 12,
                  ),
                  (item.amount * item.price).toStringAsFixed(2),
                  TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontFamily: 'poppins_semibold',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                flex: 37,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      lan.getTranslatedText('quantity'),
                      style: TextStyle(
                        fontFamily: 'poppins_regular',
                        fontSize: 12,
                        color: ThemeModule.cBlackWhiteColor,
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeModule.cForeColor),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          item.amount.toStringAsFixed(2),
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'poppins_semibold',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 63,
                child: Widgets().getRichText(
                  lan.getTranslatedText('discount'),
                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontFamily: 'poppins_regular',
                    fontSize: 12,
                  ),
                  item.discount.toStringAsFixed(0) + '%',

                  TextStyle(
                    color: ThemeModule.cBlackWhiteColor,
                    fontSize: 12,
                    fontFamily: 'poppins_semibold',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
