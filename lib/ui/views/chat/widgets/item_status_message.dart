import 'package:flutter/material.dart';
import 'package:dgg/datamodels/message.dart';

class ItemStatusMessage extends StatelessWidget {
  final StatusMessage message;
  final double textFontSize;
  final double iconSize;
  final bool isHighlightOn;

  const ItemStatusMessage({
    required this.message,
    required this.textFontSize,
    required this.iconSize,
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
      ),
    );
  }
}
