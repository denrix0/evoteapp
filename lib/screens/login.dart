import 'package:evoteapp/screens/process.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/styles.dart';
import '../main.dart';

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
    // TODO: implement initState
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width - 50,
              child: TextField(
                onChanged: (text) {
                  prefs.setString("server_id", text);
                },
                autofocus: true,
                enableSuggestions: false,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                    label: Text("Server IP"),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Login',
                style: TextStyles.textTitleStyle(),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width - 50,
              child: TextField(
                controller: _idCtrl,
                enableSuggestions: false,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    label: Text("ID"),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width - 50,
              child: TextField(
                controller: _pinCtrl,
                textInputAction: TextInputAction.go,
                onSubmitted: (string) => authManager.authLogin(
                    context,
                    _serverField.text,
                    _idCtrl.text,
                    _pinCtrl.text,
                    MaterialPageRoute(
                        builder: (context) => const AuthenticatePage())),
                decoration: const InputDecoration(
                    label: Text("PIN"),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                    builder: (context) => const AuthenticatePage()), (route) => false),//authManager.authLogin(
                // context,
                // _serverField.text,
                // _idCtrl.text,
                // _pinCtrl.text,
                // MaterialPageRoute(
                //     builder: (context) => const AuthenticatePage())),
                // TODO: reset
                child: const Text("Verify PIN"))
          ],
        ),
      ),
    );
  }
}