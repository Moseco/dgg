import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';

class ItemBroadcastMessage extends StatelessWidget {
  final BroadcastMessage message;
  final double textFontSize;
  final bool isHighlightOn;

  const ItemBroadcastMessage({
    required this.message,
    required this.textFontSize,
    required this.isHighlightOn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isHighlightOn ? 0.4 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: RichText(
          text: TextSpan(
            text: message.data,
            style: TextStyle(
              fontSize: textFontSize,
              color: const Color(0xFFEDEA12),
            ),
          ),
        ),
      ),
    );
  }
}
