import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';

class ItemUserMessage extends StatelessWidget {
  final UserMessage message;

  const ItemUserMessage({
    Key key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: message.user.nick,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: message.color == null ? null : Color(message.color),
              ),
            ),
            TextSpan(
              text: ": ",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: message.data,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
