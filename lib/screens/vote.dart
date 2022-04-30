import 'package:flutter/material.dart';

import '../components/styles.dart';
import 'confirmation.dart';

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
