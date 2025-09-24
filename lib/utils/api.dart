import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mplusanalyzer/models/http_response.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/language_pack.dart';
import 'package:mplusanalyzer/utils/messages.dart';

class API {
  LanguagePack languagePack = LanguagePack();

  Future getAuthorization_(Map bodydata) async {
    String url_ = '${GlobalParams.serverName}/api/Tokens/GetToken';
    Uri url = Uri.parse(url_);
    var body = json.encode(bodydata);
    http.Response response = http.Response("{}", 999);
    try {
      response = await http
          .post(url, headers: {"Content-Type": "application/json"}, body: body)
          .timeout(Duration(seconds: 10));
    } catch (e) {
      response = http.Response(e.toString(), 987);
    }
    return response;
  }

  Future<HttpResponseModel> request_(
    BuildContext context,
    String methodType,
    String methodName,
    Map body,
  ) async {
    Messages messages = Messages(context: context);
    HttpResponseModel httpResponseModel = HttpResponseModel(
      code: 999,
      message: '',
    );
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${GlobalParams.userParams.userToken}',
    };
    var body_ = json.encode(body);
    Uri url = Uri.parse(GlobalParams.serverName + '/api/' + methodName);

    try {
      var request = http.Request(methodType, url);
      request.body = body_;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 20),
      );

      httpResponseModel.code = response.statusCode;
      httpResponseModel.message = await response.stream.bytesToString();
      if (response.statusCode == 401) {
        await GlobalParams().logout();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
        return httpResponseModel;
      } else if (response.statusCode == 403) {
        if (context.mounted) {
          messages.showSnackBar(
            languagePack.getTranslatedText('youDontHavePermission'),
            0,
          );
          return httpResponseModel;
        }
      } else if (response.statusCode != 200) {
        if (context.mounted) {
          String errorMessage = httpResponseModel.message;
          messages.showWarningDialog(errorMessage);
          return httpResponseModel;
        }
      }
    } catch (e) {
      messages.showSnackBar(e.toString(), 0);
    }
    return httpResponseModel;
  }

  Future<HttpResponseModel> requestGeneral_(
    BuildContext context,
    String methodType,
    String url_,
  ) async {
    Messages messages = Messages(context: context);
    HttpResponseModel httpResponseModel = HttpResponseModel(
      code: 999,
      message: '',
    );

    Uri url = Uri.parse(url_);

    try {
      var request = http.Request(methodType, url);

      http.StreamedResponse response = await request.send().timeout(
        Duration(seconds: 20),
      );

      httpResponseModel.code = response.statusCode;
      httpResponseModel.message = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        if (context.mounted) {
          String errorMessage = response.reasonPhrase.toString();
          messages.showWarningDialog(errorMessage);
          return httpResponseModel;
        }
      }
    } catch (e) {
      messages.showSnackBar(e.toString(), 0);
    }
    return httpResponseModel;
  }

  Future<http.StreamedResponse> requestStream_(
    BuildContext context,
    String methodType,
    String methodName,
    Map body,
  ) async {
    Messages messages = Messages(context: context);

    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${GlobalParams.userParams.userToken}',
    };
    var body_ = json.encode(body);
    Uri url = Uri.parse(GlobalParams.serverName + '/api/' + methodName);

    late http.StreamedResponse response;

    try {
      var request = http.Request(methodType, url);
      request.body = body_;
      request.headers.addAll(headers);

      response = await request.send().timeout(Duration(seconds: 7));

      if (response.statusCode == 401) {
        await GlobalParams().logout();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
        }
        return response;
      } else if (response.statusCode == 403) {
        if (context.mounted) {
          messages.showSnackBar('Səlahiyyətiniz yoxdur!', 0);
          return response;
        }
      } else if (response.statusCode != 200) {
        if (context.mounted) {
          String errorMessage = response.reasonPhrase.toString();
          messages.showWarningDialog(errorMessage);
          return response;
        }
      }
    } catch (e) {
      messages.showWarningDialog(e.toString());
    }
    return response;
  }
}
