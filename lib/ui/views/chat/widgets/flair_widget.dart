import 'package:flutter/material.dart';
import 'package:dgg/datamodels/flairs.dart';

class FlairWidget extends StatelessWidget {
  final Flair flair;
  final double flairHeight;

  const FlairWidget({
    required this.flair,
    required this.flairHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (flair.image == null) {
      return Container();
    } else {
      return Container(
        padding: const EdgeInsets.only(right: 5),
        height: flairHeight,
        child: flair.image,
      );
    }
  }
}
