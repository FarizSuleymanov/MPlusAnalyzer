import 'package:flutter/material.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/utils/utils.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String fileNameSuffix = '';

  LanguagePack lang = LanguagePack();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  height: 50,
                  child: Text(
                    lang.getTranslatedText('settings'),
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'poppins_medium',
                    ),
                  ),
                ),
              ),
            ],
          ),
          userInfoCard(),
          SizedBox(height: 40),
          settingsMenuItem(
            'assets/icons/about.png',
            lang.getTranslatedText('about'),
            testClick,
          ),

          settingsMenuItem(
            'assets/icons/security.png',
            lang.getTranslatedText('password'),
            testClick,
          ),
          settingsMenuItem(
            'assets/icons/language.png',
            lang.getTranslatedText('language'),
            addBottomSheet,
          ),
          settingsMenuItem(
            'assets/icons/exit.png',
            lang.getTranslatedText('logout'),
            () {
              Navigator.pushReplacementNamed(context, '/login');
              GlobalParams().logout();
            },
          ),
        ],
      ),
    );
  }

  // get application version number.
  Widget getAppVersion() {
    return FutureBuilder<String>(
      future: () async {
        String version = await Utils().getVersion();
        return '${lang.getTranslatedText('version')}: $version';
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Widgets().getLoadingWidget(context);
        } else if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: const TextStyle(fontSize: 14, fontFamily: 'poppins_regular'),
          );
        } else {
          return const Text('empty');
        }
      },
    );
  }

  // create user info card
  Widget userInfoCard() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(right: 10),
            child: Image.asset('assets/icons/user.png', width: 80, height: 80),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                GlobalParams.userParams.userFullName,
                style: TextStyle(fontSize: 18, fontFamily: 'poppins_medium'),
              ),
              SizedBox(height: 3),
              Text(
                GlobalParams.params.companyName,
                style: TextStyle(fontSize: 14, fontFamily: 'poppins_regular'),
              ),
              getAppVersion(),
            ],
          ),
        ],
      ),
    );
  }

  Widget settingsMenuItem(
    String itemIconPath,
    String itemName,
    void Function() onClick,
  ) {
    return Column(
      children: [
        TextButton(
          onPressed: () => onClick(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 20,
                padding: EdgeInsets.only(right: 20),
                child: Image.asset(itemIconPath, width: 25, height: 25),
              ),
              Text(
                itemName,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'poppins_regular',
                  color: ThemeModule.cBlackWhiteColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.0),
      ],
    );
  }

  testClick() {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
        content: Center(
          child: Text('--', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  // language panel
  Widget languagePanelData() {
    List<String> languages = LanguagePack().getKeys();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: languages.map((language) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 50, right: 15),
              child: Image.asset('assets/icons/${language}.png'),
            ),
            TextButton(
              child: Text(
                LanguagePack().getTranslatedText(language),
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'poppins_medium',
                  color: ThemeModule.cBlackWhiteColor,
                ),
              ),
              onPressed: () async {
                await GlobalParams().setLanguage(language);
                if (mounted) {
                  Navigator.pop(context);
                }
                setState(() {});
              },
            ),
          ],
        );
      }).toList(),
    );
  }

  //show modal bottom sheet for choosing language
  addBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.only(top: 10.0, bottom: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
            image: DecorationImage(
              image: AssetImage('assets/main_background.png'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
              repeat: ImageRepeat.noRepeat,
            ),
          ),
          //height: 250,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                languagePanelData(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    LanguagePack().getTranslatedText('close'),
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'poppins_regular',
                      color: ThemeModule.cBlackWhiteColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
