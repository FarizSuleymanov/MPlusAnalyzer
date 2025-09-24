import 'package:flutter/material.dart';

class ThemeModule {
  ThemeData getTheme() {
    return ThemeData(
      fontFamily: 'poppins_regular',
      scaffoldBackgroundColor: cScaffoldBackgroundColor,
      appBarTheme: AppBarTheme(backgroundColor: cForeColor),
      scrollbarTheme: tScrollbarTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: cForeColor,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cForeColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return cForeColor;
          }
          return Colors.transparent;
        }),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: cScaffoldBackgroundColor,
        surface: cScaffoldBackgroundColor,
        primary: cForeColor,
      ),
      useMaterial3: true,
    ); //Opt in to Material 3.);
  }

  //Light Colors
  static Color cScaffoldBackgroundColor = const Color(0xffB4DADA);
  static Color cForeColor = const Color(0xff00C0C0);
  static Color cElevatedButtonLoginColor = Color(0xff393939);
  static Color cTextFieldLabelColor = Color(0xff8391A1);
  static Color cTextFieldFillColor = Color(0xffF7F8F9);
  static Color cContainerInfoColor = Color(0xffFCD754);
  static Color cWhiteBlackColor = Color(0xffFFFFFF);
  static Color cBlackWhiteColor = Color(0xff0c0c0c);
  static Color cScrollbarColor = const Color(0xff80e1e1);
  static Color cRadialGaugeBackgroundColor = const Color(0xffDBE4FE);
  static Color cGreenColor = const Color.fromARGB(255, 67, 194, 67);
  static Color cLightGreenColor = const Color.fromARGB(255, 177, 216, 177);

  ScrollbarThemeData tScrollbarTheme = const ScrollbarThemeData().copyWith(
    thumbColor: WidgetStateProperty.all(cScrollbarColor),
    thumbVisibility: const WidgetStatePropertyAll(true),
    interactive: true,
  );
}
