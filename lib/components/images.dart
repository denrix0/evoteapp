import 'dart:math';

import 'package:flutter/material.dart';

class VoteImage extends StatelessWidget {
  const VoteImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<double> barValues = List.generate(4, (index) => Random().nextDouble());
    return SizedBox(
      width: 400,
      height: 400,
      child: Row(
        children: [
          
        ],
      ),
    );
  }
}
