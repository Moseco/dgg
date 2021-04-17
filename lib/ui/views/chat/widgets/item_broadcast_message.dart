import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';

class ItemBroadcastMessage extends StatelessWidget {
  final BroadcastMessage message;

  const ItemBroadcastMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: RichText(
        text: TextSpan(
          text: message.data,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFEDEA12),
          ),
        ),
      ),
    );
  }
}
