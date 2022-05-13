import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:flutter/material.dart';
import 'package:dgg/datamodels/message.dart';

class ItemComboMessage extends StatelessWidget {
  final bool isHighlightOn;
  final ComboMessage message;
  final double textFontSize;
  final double emoteHeight;

  const ItemComboMessage({
    Key? key,
    required this.isHighlightOn,
    required this.message,
    required this.textFontSize,
    required this.emoteHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              child: Opacity(
                opacity: isHighlightOn ? 0.4 : 1.0,
                child: EmoteWidget(
                  emote: message.emote,
                  emoteHeight: emoteHeight,
                ),
              ),
            ),
            TextSpan(
              text: " ${message.comboCount} X C-C-C-COMBO",
              style: TextStyle(
                fontSize: textFontSize,
                fontWeight: FontWeight.bold,
                color: isHighlightOn ? Colors.white.withOpacity(0.4) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
