import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';

class ItemBroadcastMessage extends StatelessWidget {
  final BroadcastMessage message;
  final double textFontSize;

  const ItemBroadcastMessage({
    Key? key,
    required this.message,
    required this.textFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: RichText(
        text: TextSpan(
          text: message.data,
          style: TextStyle(fontSize: textFontSize, color: const Color(0xFFEDEA12)),
        ),
      ),
    );
  }
}
