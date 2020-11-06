import 'package:flutter/material.dart';
import 'package:dgg/datamodels/emotes.dart';

class EmoteWidget extends StatelessWidget {
  final Emote emote;

  EmoteWidget({
    Key key,
    @required this.emote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (emote.image == null) {
      return SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(),
      );
    } else {
      return Container(
        height: 30,
        child: emote.image,
      );
    }
  }
}
