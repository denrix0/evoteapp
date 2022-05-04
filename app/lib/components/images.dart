import 'package:flutter/material.dart';

import 'package:evoteapp/auth/auth_manager.dart';
import 'package:evoteapp/components/structures.dart';

class VoteImage extends StatelessWidget {
  const VoteImage({Key? key}) : super(key: key);

  static const List<int> barValues = [50, 90, 40, 60];

  @override
  Widget build(BuildContext context) {
    Color _imageColor = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(border: Border.all(width: 4.0, color: _imageColor), borderRadius: const BorderRadius.all(Radius.circular(8.0))),
      width: 140,
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            4,
            (index) => Container(
                  decoration: BoxDecoration(color: _imageColor),
                  width: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: barValues[index].toDouble(),
                )),
      ),
    );
  }
}

class AuthImage extends StatefulWidget {
  final authType aType;

  const AuthImage({Key? key, required this.aType}) : super(key: key);

  @override
  State<AuthImage> createState() => AuthImageState();
}

class AuthImageState extends State<AuthImage> {
  late IconData authIcon;

  @override
  Widget build(BuildContext context) {
    switch (widget.aType) {
      case authType.tOtp1:
        authIcon = Icons.phone_android;
        break;
      case authType.tOtp2:
        authIcon = Icons.more_horiz;
        break;
      case authType.uniqueID:
        authIcon = Icons.perm_identity;
        break;
    }
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (AuthManager.checkList[widget.aType.typeString]
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary)
              .withAlpha(200),),
      child: Icon(
        authIcon,
        color: Colors.black,
        size: MediaQuery.of(context).size.width - 200,
      ),
    );
  }
}

