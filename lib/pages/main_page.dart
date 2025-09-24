import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mplusanalyzer/models/user_params.dart';
import 'package:mplusanalyzer/pages/home_page.dart';
import 'package:mplusanalyzer/pages/settings_page.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class MainPage extends StatefulWidget {
  final int pageIndex;
  const MainPage({required this.pageIndex, super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  bool isLoading = true;
  bool isFirstRun = true;

  checkUserSessionAndOtherOperations() async {
    try {
      UserParams userParams = GlobalParams.userParams;
      if (userParams.userToken == '') {
        await logout();
      } else {
        bool isTokenExpired = JwtDecoder.isExpired(userParams.userToken);
        if (isTokenExpired) {
          await logout();
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      await logout();
    }
  }

  logout() {
    GlobalParams().logout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        ModalRoute.withName('/'),
      );
    });
  }

  @override
  void initState() {
    currentPageIndex = widget.pageIndex;
    checkUserSessionAndOtherOperations();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentPageIndex == 1 ? Colors.white : null,
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: NavigationBar(
          height: 65,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          //animationDuration: Duration(seconds: 3),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: currentPageIndex,
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Image.asset(
                'assets/icons/home_s.png',
                width: 36,
                height: 36,
              ),
              icon: Image.asset('assets/icons/home.png', width: 36, height: 36),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Image.asset(
                'assets/icons/settings_s.png',
                width: 36,
                height: 36,
              ),
              icon: Image.asset(
                'assets/icons/settings.png',
                width: 36,
                height: 36,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: !isLoading
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: currentPageIndex == 1
                        ? AssetImage('assets/settings_background.png')
                        : AssetImage('assets/main_background.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    repeat: ImageRepeat.noRepeat,
                  ),
                ),
                child: SafeArea(
                  child: [HomePage(), SettingsPage()][currentPageIndex],
                ),
              )
            : Widgets().getLoadingWidget(context),
      ),
    );
  }
}
