import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';

import 'package:evoteapp/auth/auth_manager.dart';
import 'package:evoteapp/components/styles.dart';

class FinalPage extends StatelessWidget {
  final String title;
  final String message;

  const FinalPage({Key? key, required this.title, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Email email = Email(
      body: """
      Error: $message
      UserID: ${AuthManager.userId}
      """,
      subject: ('Vote Issue : ' + title),
      recipients: ['example@e.mail'],
      isHTML: false,
    );

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
            const Divider(
              height: 40,
              color: Colors.transparent,
            ),
            Text(
              message,
              style: TextStyles.textDefaultStyle(context),
            ),
            const Divider(
              height: 80,
              color: Colors.transparent,
            ),
            TextButton(
                onPressed: () => SystemNavigator.pop(),
                style: ButtonStyles.defaultButton(context),
                child: Text(
                  "Close",
                  style: TextStyles.textButtonStyle(),
                )),
            const Divider(
              height: 20,
              color: Colors.transparent,
            ),
            if (title != "Vote Cast" && AuthManager.userId != null)
              TextButton(
                  onPressed: () => FlutterEmailSender.send(email),
                  style: ButtonStyles.defaultButton(context),
                  child: Text(
                    "Contact Support",
                    style: TextStyles.textButtonStyle(),
                  ))
          ],
        ),
      )),
    );
  }
}
