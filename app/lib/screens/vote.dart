import 'package:flutter/material.dart';

import 'package:evoteapp/auth/auth_manager.dart';
import 'package:evoteapp/auth/validation/crypto_functions.dart';
import 'package:evoteapp/components/styles.dart';
import 'package:evoteapp/main.dart';
import 'package:evoteapp/screens/confirmation.dart';

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
    Map voteResponse =
        await authManager.castVote(_masterToken, _selectedChoice);

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
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64.0),
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
                          snapshot.hasData ? snapshot.data['prompt'] : "Question", style: TextStyles.textDefaultStyle(context), textAlign: TextAlign.center,),
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
                    const Divider(height: 20, color: Colors.transparent,),
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
                        style: ButtonStyles.defaultButton(context),
                        child: const Text("Vote"))
                        : const Text("Not loaded")
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
