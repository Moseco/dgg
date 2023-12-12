import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:flutter/material.dart';
import 'package:dgg/datamodels/message.dart';

class ItemComboMessage extends StatelessWidget {
  final ComboMessage message;
  final double textFontSize;
  final double emoteHeight;
  final bool isHighlightOn;

  const ItemComboMessage({
    required this.message,
    required this.textFontSize,
    required this.emoteHeight,
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
                child: EmoteWidget(
                  emote: message.emote,
                  emoteHeight: emoteHeight,
                ),
              ),
              TextSpan(
                text: " ${message.comboCount} X C-C-C-COMBO",
                style: TextStyle(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
