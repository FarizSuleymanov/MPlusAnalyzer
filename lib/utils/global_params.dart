import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mplusanalyzer/models/params.dart';
import 'package:mplusanalyzer/models/user_params.dart';

class GlobalParams {
  static SessionManager _session = SessionManager();
  static String _language = 'az';
  static late UserParams _userParams;
  static late Params _params;
  static bool _isSyncCompleted = true;
  static String _serverName = 'http://10.100.10.2:1995';

  static String get language => _language;
  Future<void> setLanguage(String value) async {
    _language = value;
    await _session.set('language', value);
  }

  static String get serverName => _serverName;
  Future<void> setServerName(String value) async {
    _serverName = value;
    await _session.set('serverName', value);
  }

  static UserParams get userParams => _userParams;
  Future<void> setUserParams(UserParams value) async {
    _userParams = value;
    await _session.set('userParams', value);
  }

  static Params get params => _params;
  Future<void> setParams(Params value) async {
    _params = value;
    await _session.set('params', value);
  }

  static bool get isSyncCompleted => _isSyncCompleted;
  Future<void> setIsSyncCompleted(bool value) async {
    _isSyncCompleted = value;
    await _session.set('isSyncCompleted', value);
  }

  Future<void> syncWithSession() async {
    await _updateSession();
  }

  Future<void> _updateSession() async {
    dynamic sessionLang = await _session.get('language');
    if (sessionLang != null && sessionLang is String) {
      await setLanguage(sessionLang);
    } else {
      await _session.set('language', GlobalParams.language);
    }

    dynamic sessionServerName = await _session.get('serverName');
    if (sessionServerName != null && sessionServerName is String) {
      await setServerName(sessionServerName);
    } else {
      await _session.set('serverName', GlobalParams.serverName);
    }

    dynamic sessionUserParams = await _session.get('userParams');
    if (sessionUserParams != null) {
      await setUserParams(UserParams.fromJson(sessionUserParams));
    }

    dynamic sessionParams = await _session.get('params');
    if (sessionParams != null) {
      await setParams(Params.fromJson(sessionParams));
    }

    dynamic sessionIsSyncCompleted = await _session.get('isSyncCompleted');
    if (sessionIsSyncCompleted != null) {
      await setIsSyncCompleted(sessionIsSyncCompleted);
    } else {
      await _session.set('isSyncCompleted', GlobalParams.isSyncCompleted);
    }
  }

  Future<void> logout() async {
    await _session.remove('userParams');
    await _session.remove('params');
  }
}
