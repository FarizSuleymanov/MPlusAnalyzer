import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/models/params.dart';
import 'package:mplusanalyzer/models/user_params.dart';
import 'package:mplusanalyzer/utils/api.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../utils/language_pack.dart';
import '../utils/license.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController txtUsername = TextEditingController(),
      txtPassword = TextEditingController();
  LanguagePack lan = LanguagePack();
  bool isObscureText = true, isLoading = false, isFormLoading = true;
  String errorText = '';
  Map<String, dynamic> fieldsData = {};

  Future<void> setFields() async {
    try {
      dynamic lastUser = await SessionManager().get('lastUser');
      if (lastUser != null) {
        txtUsername.text = lastUser.toString();
      }
    } catch (e) {}

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Color elevatedButtonLoginColor = ThemeModule.cElevatedButtonLoginColor;
    Color textFieldLabelColor = ThemeModule.cTextFieldLabelColor;
    Color textFieldFillColor = ThemeModule.cTextFieldFillColor;

    fieldsData = {
      'version': packageInfo.version,
      'loginButtonColor': elevatedButtonLoginColor,
      'textFieldLabelColor': textFieldLabelColor,
      'textFieldFillColor': textFieldFillColor,
    };

    setState(() {
      isFormLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setFields();
  }

  checkLoginAndOpenMainPage(String mail, String password) async {
    setState(() {
      isLoading = true;
    });
    var uuid = const Uuid();
    String uuid_ = uuid.v6().replaceAll('-', '');

    var passBytes = utf8.encode(password);
    var passSha1 = sha1.convert(passBytes);
    String parametr = '${mail}_|_${passSha1}';

    parametr = License().encryptData(parametr, uuid_);

    Map body = {"param": parametr, "processId": uuid_};
    Response response = await API().getAuthorization_(body);
    if (!context.mounted) return;
    if (response.statusCode == 200) {
      if (!mounted) return;
      int usrRole = await setResponseDataToGlobalAndGetRoll(
        response.body,
        uuid_,
      );
      if (usrRole == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/main',
            ModalRoute.withName('/'),
          );
        });
      } else {
        txtPassword.clear();
        errorText = lan.getTranslatedText('usernameOrPasswordIsIncorrect');
      }
    } else if (response.statusCode == 400) {
      txtPassword.clear();
      errorText = lan.getTranslatedText('usernameOrPasswordIsIncorrect');
    } else if (response.statusCode == 409) {
      errorText = lan.getTranslatedText(response.body.toString());
    } else {
      errorText = lan.getTranslatedText('anErrorOccurred');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<int> setResponseDataToGlobalAndGetRoll(
    String responseBody,
    String uuid_,
  ) async {
    String token = License().decryptData(responseBody, uuid_);
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    UserParams userParams = UserParams(
      userToken: token,
      userUID: decodedToken["UserGuid"],
      userFullName: decodedToken["UserFullName"],
      confrontMod: int.tryParse(decodedToken["ConfrontMod"]) ?? 0,
      benchmarkMod: int.tryParse(decodedToken["BenchmarkMod"]) ?? 0,
      countingMod: int.tryParse(decodedToken["CountingMod"]) ?? 0,
      faqMod: int.tryParse(decodedToken["FaqMod"]) ?? 0,
      countingStockVisibility: decodedToken["CountingStockVisibility"] == 'True'
          ? 1
          : 0,
      userCompanyName: '', //decodedToken["UserCompanyName"],
    );
    int role = int.tryParse(decodedToken["role"]) ?? 0;
    await GlobalParams().setUserParams(userParams);

    String url_ = "Settings/GetParameters";
    HttpResponseModel response = await API().request_(
      context,
      'POST',
      url_,
      {},
    );
    Params params = Params(
      companyName: '',
      chiefAccountant: '',
      assistantAccountant: '',
      googleApiKey: '',
      countingItemsOrderBy: '0',
    );
    if (response.code == 200) {
      List list = jsonDecode(response.message) as List;
      for (var e in list) {
        switch (e['name']) {
          case 'CompanyName':
            params.companyName = e['value'];
            break;
          case 'ChiefAccountant':
            params.chiefAccountant = e['value'];
            break;
          case 'AssistantAccountant':
            params.assistantAccountant = e['value'];
            break;
          case 'GoogleApiKey':
            params.googleApiKey = e['value'];
            break;
          case 'CountingItemsOrderBy':
            params.countingItemsOrderBy = e['value'];
            break;
        }
      }
    }
    await GlobalParams().setParams(params);

    SessionManager().set('lastUser', txtUsername.text);
    return role;
  }

  void login() async {
    if (!isLoading) {
      checkLoginAndOpenMainPage(txtUsername.text, txtPassword.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
            repeat: ImageRepeat.noRepeat,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: !isFormLoading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    lan.getTranslatedText('entry'),
                                    style: TextStyle(
                                      fontSize: 26,
                                      color: Colors.white,
                                      fontFamily: 'urbanist',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Widgets().getTextFormField(
                                  txtUsername,
                                  (v) {},
                                  [LengthLimitingTextInputFormatter(50)],
                                  'userName',
                                  fieldsData['textFieldLabelColor'],
                                  fieldsData['textFieldFillColor'],
                                  false,
                                  TextInputType.text,
                                ),
                                SizedBox(height: 15),
                                Widgets().getTextFormFieldForPassword(
                                  txtPassword,
                                  (v) {},
                                  [LengthLimitingTextInputFormatter(50)],
                                  lan.getTranslatedText('password'),
                                  fieldsData['textFieldLabelColor'],
                                  fieldsData['textFieldFillColor'],
                                  isObscureText,
                                  () {
                                    setState(() {
                                      isObscureText = !isObscureText;
                                    });
                                  },
                                ),
                                SizedBox(height: 10),
                                errorText != ''
                                    ? Container(
                                        child: Center(
                                          child: Text(
                                            errorText,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: 'poppins_medium',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => login(),
                                    child: isLoading
                                        ? Container(
                                            height: 20,
                                            width: 20,
                                            child: Widgets().getLoadingWidget(
                                              context,
                                            ),
                                          )
                                        : Text(
                                            lan.getTranslatedText('login'),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                      ),
                                      backgroundColor:
                                          fieldsData['loginButtonColor'],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      'assets/icons/icon_on_login.png',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      fieldsData['version'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Widgets().getLoadingWidget(context),
              ),
              Positioned(
                right: 10,
                top: 0,
                child: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/conn');
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
