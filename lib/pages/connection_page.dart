import 'package:flutter/material.dart';
import 'package:mplusanalyzer/utils/global_params.dart';
import 'package:mplusanalyzer/utils/messages.dart';
import 'package:mplusanalyzer/utils/theme_module.dart';
import 'package:mplusanalyzer/widgets/widgets.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({super.key});

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  TextEditingController txtServerLink = TextEditingController();

  saveConnectionPage() async {
    await GlobalParams().setServerName(txtServerLink.text);
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        ModalRoute.withName('/'),
      );
      Messages(context: context).showSnackBar('Yadda saxlanıldı', 1);
    }
  }

  @override
  void initState() {
    super.initState();
    txtServerLink.text = GlobalParams.serverName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nizamlamalar'),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              ModalRoute.withName('/'),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveConnectionPage();
        },
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: Center(
        child: SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Widgets().getTextFormField(
                      txtServerLink,
                      (v) {},
                      [],
                      'server',
                      ThemeModule.cTextFieldLabelColor,
                      ThemeModule.cTextFieldFillColor,
                      false,
                      TextInputType.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
