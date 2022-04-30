import 'dart:async';

import 'package:evoteapp/screens/vote_page.dart';
import 'package:flutter/material.dart';

import 'package:evoteapp/components/structures.dart';

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
                    style: ButtonStyles.buttonStyleNav(),
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
                                    ? const Color.fromRGBO(111, 147, 255, 0.9)
                                    : const Color.fromRGBO(
                                        111, 147, 255, 0.4))));
                  }),
                ),
                TextButton(
                    onPressed: () => _currentIndex < pageItems.length - 1
                        ? pageController.animateToPage(++_currentIndex,
                            duration: _swipeTime, curve: Curves.easeIn)
                        : null,
                    style: ButtonStyles.buttonStyleNav(),
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
                color: !AuthManager.checkList['totp1']
                    ? Colors.grey
                    : Colors.green),
            child: Icon(
              Icons.check,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            controller: _textCtrl,
            enableSuggestions: false,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp1),
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(context, setState,
                _textCtrl.text, authType.tOtp1), //verifyOTP(context),
            child: const Text("Verify Code"))
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
                color: !AuthManager.checkList['totp2']
                    ? Colors.grey
                    : Colors.green),
            child: Icon(
              Icons.phone_android,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            controller: _textCtrl,
            textInputAction: TextInputAction.go,
            enableSuggestions: false,
            keyboardType: TextInputType.number,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp2),
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.tOtp2),
            child: const Text("Verify Code"))
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
                color:
                    !AuthManager.checkList['uid'] ? Colors.grey : Colors.green),
            child: Icon(
              Icons.perm_identity,
              size: MediaQuery.of(context).size.width - 200,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            controller: _textCtrl,
            textInputAction: TextInputAction.go,
            onSubmitted: (string) => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.uniqueID),
            enableSuggestions: false,
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, setState, _textCtrl.text, authType.uniqueID),
            child: const Text("Verify ID"))
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
            return CheckboxListTile(
                title: Text(_idToName[_items[index]]),
                value: AuthManager.checkList[_items[index]],
                onChanged: null);
          }),
        ),
      ),
      TextButton(
          onPressed: () {
            if (!AuthManager.checkList.values.contains(false) || true) { //TODO: reset
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const VotePage()),
                  (route) => false);
            }
          },
          child: Text(
            "Connect",
            style: TextStyles.textDefaultStyle(),
          ))
    ]);
  }
}
