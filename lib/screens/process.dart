import 'dart:async';

import 'package:evoteapp/screens/vote.dart';
import 'package:flutter/material.dart';

import 'package:evoteapp/components/structures.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../auth/auth_manager.dart';
import '../components/styles.dart';
import '../main.dart';

class AuthenticatePage extends StatefulWidget {
  const AuthenticatePage({Key? key}) : super(key: key);

  @override
  _AuthenticatePageState createState() => _AuthenticatePageState();
}

class _AuthenticatePageState extends State<AuthenticatePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final pageController = PageController();
  final _swipeTime = const Duration(milliseconds: 300);
  int _currentIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static List<StatefulWidget> pageItems = const [
    OTPAuth(),
    SecDeviceAuth(),
    IDAuth(),
    FinishAuth()
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: PageView(
                controller: pageController,
                children: pageItems,
                onPageChanged: onPageChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => _currentIndex > 0
                        ? pageController.animateToPage(--_currentIndex,
                            duration: _swipeTime, curve: Curves.easeIn)
                        : null,
                    style: ButtonStyles.buttonNav(),
                    child: const Icon(Icons.navigate_before)),
                Row(
                  children: List.generate(pageItems.length, (index) {
                    return InkWell(
                        onTap: () {
                          _currentIndex == index;
                          pageController.animateToPage(index,
                              duration: _swipeTime, curve: Curves.easeIn);
                        },
                        child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .secondary)));
                  }),
                ),
                TextButton(
                    onPressed: () => _currentIndex < pageItems.length - 1
                        ? pageController.animateToPage(++_currentIndex,
                            duration: _swipeTime, curve: Curves.easeIn)
                        : null,
                    style: ButtonStyles.buttonNav(),
                    child: const Icon(Icons.navigate_next)),
              ],
            )
          ]),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class OTPAuth extends StatefulWidget {
  const OTPAuth({Key? key}) : super(key: key);

  @override
  _OTPAuthState createState() => _OTPAuthState();
}

class _OTPAuthState extends State<OTPAuth> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'TOTP',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AuthManager.checkList['totp1']
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary)
                    .withAlpha(200)),
            child: Icon(
              Icons.phone_android,
              color: Colors.black,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: PinCodeTextField(
            controller: _textCtrl,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp1),
            textStyle: TextStyles.textDefaultStyle(context),
            pinTheme: TextInputStyle.pinTheme(context),
            onChanged: (String value) {},
            length: 6,
            appContext: context,
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp1),
            style: ButtonStyles.buttonVerify(context), //verifyOTP(context),
            child: const Text("Verify"))
      ],
    );
  }
}

class SecDeviceAuth extends StatefulWidget {
  const SecDeviceAuth({Key? key}) : super(key: key);

  @override
  _SecDeviceAuthState createState() => _SecDeviceAuthState();
}

class _SecDeviceAuthState extends State<SecDeviceAuth> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Secondary TOTP',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AuthManager.checkList['totp2']
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary)
                    .withAlpha(200)),
            child: Icon(
              Icons.more_horiz,
              color: Colors.black,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: PinCodeTextField(
            controller: _textCtrl,
            textInputAction: TextInputAction.go,
            textStyle: TextStyles.textDefaultStyle(context),
            pinTheme: TextInputStyle.pinTheme(context),
            keyboardType: TextInputType.number,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp2),
            onChanged: (String value) {},
            length: 6,
            appContext: context,
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp2),
            style: ButtonStyles.buttonVerify(context),
            child: const Text("Verify"))
      ],
    );
  }
}

class IDAuth extends StatefulWidget {
  const IDAuth({Key? key}) : super(key: key);

  @override
  _IDAuthState createState() => _IDAuthState();
}

class _IDAuthState extends State<IDAuth> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Unique ID',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (AuthManager.checkList['uid']
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary)
                    .withAlpha(200)),
            child: Icon(
              Icons.perm_identity,
              color: Colors.black,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            textAlign: TextAlign.center,
            controller: _textCtrl,
            textInputAction: TextInputAction.go,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.uniqueID),
            enableSuggestions: false,
            decoration:
                TextInputStyle.genericField("UID", context, center: true),
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.uniqueID),
            style: ButtonStyles.buttonVerify(context),
            child: const Text("Verify"))
      ],
    );
  }
}

class FinishAuth extends StatefulWidget {
  const FinishAuth({Key? key}) : super(key: key);

  @override
  _FinishAuthState createState() => _FinishAuthState();
}

class _FinishAuthState extends State<FinishAuth> {
  final Map _idToName = {
    "uid": "Unique ID",
    "totp1": "Phone TOTP",
    "totp2": "Secondary TOTP"
  };

  @override
  Widget build(BuildContext context) {
    List _items = AuthManager.checkList.keys.toList();
    return Column(children: [
      Text(
        "Authentication Status",
        style: TextStyles.textTitleStyle(),
      ),
      const Divider(
        height: 40,
        color: Colors.transparent,
      ),
      Container(
        padding: const EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height - 400,
        child: ListView(
          children: List.generate(3, (index) {
            bool _itemChecked = AuthManager.checkList[_items[index]];
            Color _color = _itemChecked ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error;
            return ListTile(
                title: Text(_idToName[_items[index]], style: TextStyles.textDefaultStyle(context, color: _color),),
                trailing: Icon(
                  _itemChecked ? Icons.check : Icons.close,
                  color: _color,
                ),
                );
          }),
        ),
      ),
      TextButton(
          onPressed: () {
            if (!AuthManager.checkList.values.contains(false)) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const VotePage()),
                  (route) => false);
            }
          },
          style: ButtonStyles.buttonContinue(context),
          child: const Text(
            "Connect",
          ))
    ]);
  }
}
