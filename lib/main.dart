import 'package:evoteapp/auth_manager.dart';
import 'package:evoteapp/styles.dart';
import 'package:flutter/material.dart';

AuthManager authManager = AuthManager();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
      home: const AuthenticatePage(),
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
    BiometricsAuth(),
    OTPAuth(),
    PinAuth(),
    GovtAuth(),
    FinishAuth()
  ];

  @override
  void initState() {
    // TODO: implement initState
    _tabCtrl = TabController(length: pageItems.length, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    // _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
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
                                    : const Color.fromRGBO(111, 147, 255, 0.4))));
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

class BiometricsAuth extends StatefulWidget {
  const BiometricsAuth({Key? key}) : super(key: key);

  @override
  _BiometricsAuthState createState() => _BiometricsAuthState();
}

class _BiometricsAuthState extends State<BiometricsAuth> {
  Map<bool, String> prompts = {
    false: 'Text asking to authenticate',
    true: 'Text saying is authenticated'
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: authManager.getBiometricAuth(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Biometric Authentication',
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
                  onPressed: () {
                    if (!AuthManager.didAuthenticateBio) {
                      setState(() {
                        // authManager.getBiometricAuth();
                      });
                    }
                  },
                  child: const Text('Retry')),
              Text(
                prompts[AuthManager.didAuthenticateBio] ?? "Loading status...",
                style: TextStyles.textDefaultStyle(),
              )
            ],
          );
        });
  }
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
            'OTP Authentication',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(64.0),
          child: Container(
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: Icon(
              Icons.check,
              size: MediaQuery.of(context).size.width - 160,
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

class PinAuth extends StatefulWidget {
  const PinAuth({Key? key}) : super(key: key);

  @override
  _PinAuthState createState() => _PinAuthState();
}

class _PinAuthState extends State<PinAuth> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'PIN Authentication',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(64.0),
          child: Container(
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: Icon(
              Icons.more_horiz,
              size: MediaQuery.of(context).size.width - 160,
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
        const TextButton(onPressed: null, child: Text("Verify PIN"))
      ],
    );
  }
}

class GovtAuth extends StatefulWidget {
  const GovtAuth({Key? key}) : super(key: key);

  @override
  _GovtAuthState createState() => _GovtAuthState();
}

class _GovtAuthState extends State<GovtAuth> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'ID Authentication',
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(64.0),
          child: Container(
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: Icon(
              Icons.perm_identity,
              size: MediaQuery.of(context).size.width - 160,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const VotePage()),
                (route) => false),
            child: Text("Connect", style: TextStyles.textDefaultStyle(),))
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
          body: Column(
            children: [
              Text(_questionText),
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
              }))
            ],
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
    return Container(child:
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Voting Server'),
          Container(
            padding: const EdgeInsets.all(8.0),
            width: 250,
            child: TextField(
              controller: _textCtrl,
              decoration:
              const InputDecoration(border: OutlineInputBorder()),
            ),
          )
        ],
      ),
    ),);
  }
}

