import 'package:flutter/material.dart';

import '../components/styles.dart';
import 'login.dart';

class FinalPage extends StatelessWidget {
  final String title;
  final String message;

  const FinalPage({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyles.textTitleStyle(),
                ),
                Text(
                  message,
                  style: TextStyles.textDefaultStyle(),
                ),
                TextButton(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false),//SystemNavigator.pop(), //TODO: reset
                    child: Text(
                      "Close",
                      style: TextStyles.textButtonStyle(),
                    ))
              ],
            ),
          )),
    );
  }
}