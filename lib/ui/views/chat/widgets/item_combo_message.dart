import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:flutter/material.dart';
import 'package:dgg/datamodels/message.dart';

class ItemComboMessage extends StatelessWidget {
  final ComboMessage message;

  const ItemComboMessage({
    Key key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            WidgetSpan(
              child: EmoteWidget(emote: message.emote),
            ),
            TextSpan(
              text: " ${message.comboCount} X C-C-C-COMBO",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
