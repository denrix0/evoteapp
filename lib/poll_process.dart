import 'dart:async';

import 'package:flutter/material.dart';

import 'package:evoteapp/auth_manager.dart';
import 'package:evoteapp/structures.dart';
import 'package:evoteapp/styles.dart';

import 'package:shared_preferences/shared_preferences.dart';

AuthManager authManager = AuthManager();

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

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  String _selectedChoice = '';
  late String _masterToken;

  Future<Map?> getOptions() async {
    // Map? form = await authManager.fetchVoteForm();
    //TODO: reset
    // _masterToken = CryptoFunctions().generateMasterToken(
    //     AuthManager.tokens['uid']!,
    //     AuthManager.tokens['totp1']!,
    //     AuthManager.tokens['totp2']!);
    Map form = {
      'prompt': 'hi',
      'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4']
    };

    _masterToken = 'hi';
    return form;
  }

  void castVote(context) async {
    // Map voteResponse =
    //     await authManager.castVote(_masterToken, _selectedChoice);

    Map voteResponse = {
      'title': 'hi',
      'message': 'loremaaaaaaaaaaaaaaaaaaaaa',
      'error': null
    };//TODO: reset

    if (voteResponse['error'] == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => FinalPage(
                    title: voteResponse['title'],
                    message: voteResponse['message'],
                  )),
          (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(voteResponse['error']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getOptions(),
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Poll Form",
                  style: TextStyles.textTitleStyle(),
                ),
                const Divider(
                  height: 40,
                  color: Colors.transparent,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                      snapshot.hasData ? snapshot.data['prompt'] : "Question"),
                ),
                snapshot.hasData
                    ? Column(
                        children: List.generate(snapshot.data['options'].length,
                            (index) {
                        return RadioListTile<String>(
                            title: Text(snapshot.hasData
                                ? snapshot.data['options'][index]
                                : "Option"),
                            value: snapshot.hasData
                                ? snapshot.data['options'][index]
                                : "Option",
                            groupValue: _selectedChoice,
                            onChanged: (value) {
                              setState(() {
                                _selectedChoice = value.toString();
                              });
                            });
                      }))
                    : const Text('Loading Options...'),
                snapshot.hasData
                    ? TextButton(
                        onPressed: () {
                          if (_selectedChoice != '') {
                            castVote(context);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Please select an option"),
                            ));
                          }
                        },
                        child: const Text("Vote"))
                    : const Text("Not loaded")
              ],
            ),
          ),
        );
      },
    );
  }
}

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
