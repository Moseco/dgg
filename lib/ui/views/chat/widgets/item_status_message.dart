import 'package:flutter/material.dart';
import 'package:dgg/datamodels/message.dart';

class ItemStatusMessage extends StatelessWidget {
  final StatusMessage message;
  final double textFontSize;
  final double iconSize;

  const ItemStatusMessage({
    Key? key,
    required this.message,
    required this.textFontSize,
    required this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              child: Icon(
                Icons.info_outline,
                size: iconSize,
                color: message.isError ? Colors.red : null,
              ),
            ),
            TextSpan(
              text: " ${message.data}",
              style: TextStyle(
                fontSize: textFontSize,
                fontWeight: FontWeight.bold,
                color: message.isError ? Colors.red : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
