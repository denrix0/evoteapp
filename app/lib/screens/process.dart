import 'package:evoteapp/auth/validation/field_validations.dart';
import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:evoteapp/components/structures.dart';
import 'package:evoteapp/components/styles.dart';
import 'package:evoteapp/components/images.dart';
import 'package:evoteapp/auth/auth_manager.dart';
import 'package:evoteapp/screens/vote.dart';
import 'package:evoteapp/main.dart';

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

  static final List _controllers = [
    {"title": "OTP", "type": authType.tOtp1},
    {"title": "Secondary OTP", "type": authType.tOtp2},
    {"title": "Unique ID", "type": authType.uniqueID},
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<StatefulWidget> pageItems = List.generate(3, (index) {
      Map currentPage = _controllers[index];
      return AuthPage(title: currentPage["title"], aType: currentPage["type"]);
    });

    pageItems.add(const FinishAuth());

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

class AuthPage extends StatefulWidget {
  final String title;
  final authType aType;
  const AuthPage({Key? key, required this.title, required this.aType})
      : super(key: key);

  @override
  _AuthPage createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
  final GlobalKey<AuthImageState> _key = GlobalKey();
  final TextEditingController _textCtrl = TextEditingController();

  Widget getTextField({bool code = true}) => code
      ? PinCodeTextField(
          controller: _textCtrl,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.go,
          beforeTextPaste: (code) {
            ValidationResult _valid = FieldValidations.validateOtp(code!);
            return _valid.errors.isEmpty;
          },
          autoDisposeControllers: false,
          onSubmitted: (string) => authManager.verifyAuth(
              context, _key, _textCtrl.text, widget.aType),
          textStyle: TextStyles.textDefaultStyle(context),
          pinTheme: TextInputStyle.pinTheme(context),
          onChanged: (String value) {},
          length: 6,
          appContext: context,
        )
      : TextField(
          textAlign: TextAlign.center,
          controller: _textCtrl,
          textInputAction: TextInputAction.go,
          onSubmitted: (string) => authManager.verifyAuth(
              context, _key, _textCtrl.text, widget.aType),
          enableSuggestions: false,
          decoration: TextInputStyle.genericField("", context, center: true),
        );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            widget.title,
            style: TextStyles.textTitleStyle(),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(32.0),
            child: AuthImage(
              key: _key,
              aType: widget.aType,
            )),
        Container(
            padding: const EdgeInsets.all(16.0),
            width: MediaQuery.of(context).size.width - 50,
            child: getTextField(code: widget.aType != authType.uniqueID)),
        TextButton(
            onPressed: () => authManager.verifyAuth(
                context, _key, _textCtrl.text, widget.aType),
            style: ButtonStyles.defaultButton(context),
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
            Color _color = _itemChecked
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error;
            return ListTile(
              title: Text(
                _idToName[_items[index]],
                style: TextStyles.textDefaultStyle(context, color: _color),
              ),
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
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBarStyles.errorSnackBar(context,
                      content:
                          "All Authentication Methods need to be verified"));
            }
          },
          style: ButtonStyles.defaultButton(context),
          child: const Text(
            "Continue",
          ))
    ]);
  }
}
