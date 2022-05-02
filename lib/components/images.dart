import 'dart:math';

import 'package:flutter/material.dart';

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
