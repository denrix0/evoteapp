import 'dart:async';

import 'package:evoteapp/auth_manager.dart';
import 'package:evoteapp/structures.dart';
import 'package:evoteapp/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crypto_functions.dart';

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

  void login(context) async {
    List<String> _errorList = [];

    bool validIp(String _ip) => RegExp(
            r'^(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))\.(\d|[1-9]\d|1\d\d|2([0-4]\d|5[0-5]))$')
        .hasMatch(_ip);

    // Validate Server Address Field
    if (_serverField.text != "") {
      String? _serverIP;
      int _serverPort = 5000;

      if (':'.allMatches(_serverField.text).length == 1) {
        List _ipPort = _serverField.text.split(':');

        if (validIp(_ipPort[0])) {
          _serverIP = _ipPort[0];
        } else {
          _errorList.add("Invalid IP address");
        }

        if (_serverPort >= 0 && _serverPort <= 65535) {
          _serverPort = _ipPort[1];
        } else {
          _errorList.add("Invalid Port");
        }
      } else if (':'.allMatches(_serverField.text).isEmpty) {
        if (validIp(_serverField.text)) {
          _serverIP = _serverField.text;
        } else {
          _errorList.add("Invalid IP address");
        }
      } else {
        _errorList.add("Invalid Server address format");
      }

      if (_serverIP != null) {
        authManager.init(_serverIP, _serverPort);
      }
    } else {
      _errorList.add("Server address field is empty");
    }

    // Validate ID
    if (_idCtrl.text != '') {
      _idCtrl.text.replaceAll(' ', '');

      if (!RegExp(r'[0-9]+').hasMatch(_idCtrl.text)) {
        _errorList.add("Invalid ID");
      }
    } else {
      _errorList.add("ID field must not be empty");
    }

    // Validate PIN
    if (_pinCtrl.text != '') {
      _pinCtrl.text.replaceAll(' ', '');

      if (_pinCtrl.text.length < 8) {
        _errorList.add("Pin must be longer than 8 characters");
      }
    }

    if (_errorList.isEmpty) {
      AuthResponse? _response =
          await authManager.getPinAuth(_idCtrl.text, _pinCtrl.text);

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthenticatePage()),
              (route) => false);
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorList.isNotEmpty ? _errorList[0] : "Logging In..."),
      ));
    }
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
                controller: _serverField,
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
                decoration: const InputDecoration(
                    label: Text("PIN"),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            TextButton(
                onPressed: () => login(context),
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

  void verifyOTP(context) async {
    List _errorList = [];

    _textCtrl.text.replaceAll(' ', '');

    if (_textCtrl.text != '') {
      if (_textCtrl.text.length != 6) {
        _errorList.add('The OTP should be 6 digits long.');
      }
      if (!RegExp(r'[0-9]+').hasMatch(_textCtrl.text)) {
        _errorList.add("The OTP should only consist of digits");
      }
    } else {
      _errorList.add("Field is empty");
    }

    if (_errorList.isEmpty) {
      AuthResponse? _response =
          await authManager.getAuth(_textCtrl.text, 'totp1');

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          setState(() {});
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request Failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorList.isNotEmpty ? _errorList[0] : "Logging In..."),
      ));
    }
  }

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
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => verifyOTP(context),
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

  void verifyOTP(context) async {
    List _errorList = [];

    _textCtrl.text.replaceAll(' ', '');

    if (_textCtrl.text != '') {
      if (_textCtrl.text.length != 6) {
        _errorList.add('The OTP should be 6 digits long.');
      }
      if (!RegExp(r'[0-9]+').hasMatch(_textCtrl.text)) {
        _errorList.add("The OTP should only consist of digits");
      }
    } else {
      _errorList.add("Field is empty");
    }

    if (_errorList.isEmpty) {
      AuthResponse? _response =
          await authManager.getAuth(_textCtrl.text, 'totp2');

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          setState(() {});
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request Failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorList.isNotEmpty ? _errorList[0] : "Logging In..."),
      ));
    }
  }

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
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => verifyOTP(context),
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

  void verifyID(context) async {
    List _errorList = [];

    _textCtrl.text.replaceAll(' ', '');

    if (_textCtrl.text != '') {
      // if (_textCtrl.text.length != 6) {
      //   _errorList.add('The OTP should be 6 digits long.');
      // }
      if (!RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(_textCtrl.text)) {
        _errorList.add("This seems invalid");
      }
    } else {
      _errorList.add("Field is empty");
    }

    if (_errorList.isEmpty) {
      AuthResponse? _response =
          await authManager.getAuth(_textCtrl.text, 'uid');

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          setState(() {});
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request Failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorList.isNotEmpty ? _errorList[0] : "Logging In..."),
      ));
    }
  }

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
            decoration: const InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide())),
          ),
        ),
        TextButton(
            onPressed: () => verifyID(context), child: const Text("Verify ID"))
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
            if (!AuthManager.checkList.values.contains(false)) {
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
    Map? form = await authManager.fetchVoteForm();
    _masterToken = CryptoFunctions().generateMasterToken(
        AuthManager.tokens['uid']!,
        AuthManager.tokens['totp1']!,
        AuthManager.tokens['totp2']!);
    return form;
  }

  void castVote(context) async {
    String? _pass;
    Map _pageContent = {'title': '', 'message': ''};

    final AuthResponse? _response =
        await authManager.sendVote(_masterToken, _selectedChoice);

    if (_response?.status == reqStatus.success) {
      if (_response?.type == resType.valid) {
        _pageContent = {
          'title': 'Vote Cast',
          'message':
              'Vote has been successfully cast. You can close the app now.'
        };
        _pass = null;
      } else if (_response?.type == resType.error) {
        _pageContent = {
          'title': 'Error Casting Vote',
          'message': _response?.content['message']
        };
        _pass = null;
      } else {
        _pass = "Could not cast vote: Unknown";
      }
    } else {
      _pass = "Could not cast vote: Request failed.";
    }

    if (_pass == null) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => FinalPage(
                    title: _pageContent['title'],
                    message: _pageContent['message'],
                  )),
          (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_pass),
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
                onPressed: () => SystemNavigator.pop(),
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
