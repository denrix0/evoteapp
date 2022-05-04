import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:evoteapp/components/images.dart';
import 'package:evoteapp/screens/process.dart';
import 'package:evoteapp/components/styles.dart';
import 'package:evoteapp/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _serverField = TextEditingController();
  late final SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initField();
  }

  void initField() async {
    prefs = await SharedPreferences.getInstance();
    String _text = prefs.getString("server_id")!;
    _serverField.value = TextEditingValue(
      text: _text,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _text.length),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 64.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VoteImage(),
                const Divider(
                  color: Colors.transparent,
                  height: 40.0,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextField(
                      onChanged: (text) {
                        prefs.setString("server_id", text);
                      },
                      controller: _serverField,
                      autofocus: true,
                      enableSuggestions: false,
                      keyboardType: TextInputType.datetime,
                      decoration:
                          TextInputStyle.genericField("Server IP", context)),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextField(
                      controller: _idCtrl,
                      enableSuggestions: false,
                      keyboardType: TextInputType.number,
                      decoration: TextInputStyle.genericField("ID", context)),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.of(context).size.width - 50,
                  child: TextField(
                    controller: _pinCtrl,
                    textInputAction: TextInputAction.go,
                    obscureText: true,
                    onSubmitted: (string) => authManager.authLogin(
                        context,
                        _serverField.text,
                        _idCtrl.text,
                        _pinCtrl.text,
                        MaterialPageRoute(
                            builder: (context) => const AuthenticatePage())),
                    decoration: TextInputStyle.genericField("PIN", context),
                  ),
                ),
                TextButton(
                    onPressed: () => authManager.authLogin(
                          context,
                          _serverField.text,
                          _idCtrl.text,
                          _pinCtrl.text,
                          MaterialPageRoute(
                              builder: (context) => const AuthenticatePage())),
                    style: ButtonStyles.defaultButton(context),
                    child: const Text("Login"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
