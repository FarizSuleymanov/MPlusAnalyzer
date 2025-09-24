import 'package:flutter/material.dart';
import 'package:mplusanalyzer/pages/connection_page.dart';
import 'package:mplusanalyzer/pages/login_page.dart';
import 'package:mplusanalyzer/pages/main_page.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalParams().syncWithSession();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MPlus Analyser',
      theme: ThemeModule().getTheme(),
      initialRoute: '/main',
      routes: {
        '/login': (context) => const LoginPage(),
        '/main': (context) => MainPage(pageIndex: 0),
        '/settings': (context) => MainPage(pageIndex: 1),
        '/conn': (context) => ConnectionPage(),
      },
    );
  }
}
