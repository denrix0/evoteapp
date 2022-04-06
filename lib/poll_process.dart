import 'package:evoteapp/auth_manager.dart';
import 'package:evoteapp/styles.dart';
import 'package:flutter/material.dart';

AuthManager authManager = AuthManager();

class BiometricsAuth extends StatefulWidget {
  const BiometricsAuth({Key? key}) : super(key: key);

  @override
  _BiometricsAuthState createState() => _BiometricsAuthState();
}

class _BiometricsAuthState extends State<BiometricsAuth> {
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
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'System Authentication',
                  style: TextStyles.textTitleStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(64.0),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AuthManager.didAuthenticateBio
                          ? Colors.green
                          : Colors.grey),
                  child: Icon(
                    Icons.fingerprint,
                    size: MediaQuery.of(context).size.width - 160,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () async {
                    if (!AuthManager.didAuthenticateBio)
                      await authManager.getBiometricAuth();
                    if (AuthManager.didAuthenticateBio) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false);
                    }
                  },
                  child: const Text('Authenticate')),
              Text(
                'Please use biometrics to unlock your phone',
                style: TextStyles.textDefaultStyle(),
              )
            ],
          )),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _pinCtrl = TextEditingController();

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
                controller: _idCtrl,
                decoration: const InputDecoration(
                    label: Text("PIN"),
                    border: OutlineInputBorder(borderSide: BorderSide())),
              ),
            ),
            TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AuthenticatePage()),
                    (route) => false),
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
  final _txtFldCtrl = TextEditingController();
  late TabController _tabCtrl;
  List<StatefulWidget> pageItems = const [
    OTPAuth(),
    SecDeviceAuth(),
    IDAuth(),
    FinishAuth()
  ];

  @override
  void initState() {
    _tabCtrl = TabController(length: pageItems.length, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    super.initState();
  }

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
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabCtrl,
                children: pageItems,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      if (_tabCtrl.index > 0) {
                        _tabCtrl.animateTo((_tabCtrl.index - 1));
                      }
                    },
                    style: ButtonStyles.buttonStyleNav(),
                    child: const Icon(Icons.navigate_before)),
                Row(
                  children: List.generate(pageItems.length, (index) {
                    return InkWell(
                        onTap: () => setState(() {
                              _tabCtrl.animateTo(index);
                            }),
                        child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _tabCtrl.index == index
                                    ? const Color.fromRGBO(111, 147, 255, 0.9)
                                    : const Color.fromRGBO(
                                        111, 147, 255, 0.4))));
                  }),
                ),
                TextButton(
                    onPressed: () {
                      if (_tabCtrl.index < pageItems.length - 1) {
                        _tabCtrl.animateTo((_tabCtrl.index + 1));
                      }
                    },
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
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
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
            onPressed: () {
              authManager.getOtpAuth('1000');
            },
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
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
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
        const TextButton(onPressed: null, child: Text("Verify Code"))
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
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
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
        const TextButton(onPressed: null, child: Text("Verify ID"))
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
  List<String> methods = ["Meth 1", "Meth 2", "Meth 3"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
          child: ListView.builder(
            itemCount: methods.length,
            itemBuilder: (BuildContext context, int index) {
              return CheckboxListTile(
                  title: Text(methods[index]), value: true, onChanged: null);
            },
          ),
        ),
        TextButton(
            onPressed: () {
              authManager.getOtpAuth("0");
            },
            child: Text(
              "Test",
              style: TextStyles.textDefaultStyle(),
            )),
        TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const VotePage()),
                (route) => false),
            child: Text(
              "Connect",
              style: TextStyles.textDefaultStyle(),
            ))
      ],
    );
  }
}

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  _VotePageState createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  late String _questionText = "Sample Question?";
  late List<String> _questionChoices = ["Option 1", "Option 2", "Option 3"];
  String _selectedChoice = '';

  Future<bool> getOptions() async {
    bool _got = false;

    _questionChoices = ["Option 1", "Option 2", "Option 3"];
    _questionText = "Sample Question?";

    return _got;
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
                  child: Text(_questionText),
                ),
                Column(
                    children: List.generate(_questionChoices.length, (index) {
                  return RadioListTile(
                      title: Text(_questionChoices[index]),
                      value: _questionChoices[index],
                      groupValue: _selectedChoice,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedChoice = value ?? '';
                        });
                      });
                })),
                TextButton(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BiometricsAuth()),
                        (route) => false),
                    child: const Text("Vote"))
              ],
            ),
          ),
        );
      },
    );
  }
}

class ServerPage extends StatefulWidget {
  const ServerPage({Key? key}) : super(key: key);

  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Voting Server'),
          Container(
            padding: const EdgeInsets.all(8.0),
            width: 250,
            child: TextField(
              controller: _textCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          )
        ],
      ),
    );
  }
}
