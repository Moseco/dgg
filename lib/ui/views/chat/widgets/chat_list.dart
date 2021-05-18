import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../chat_viewmodel.dart';
import 'item_broadcast_message.dart';
import 'item_combo_message.dart';
import 'item_status_message.dart';
import 'item_user_message.dart';

class ChatList extends ViewModelWidget<ChatViewModel> {
  final ScrollController scrollController;

  const ChatList({Key? key, required this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context, ChatViewModel model) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          if (scrollController.offset <=
                  scrollController.position.minScrollExtent &&
              !scrollController.position.outOfRange) {
            model.toggleChat(true);
          } else {
            model.toggleChat(false);
          }
        }
        return true;
      },
      child: ListView.custom(
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: scrollController,
        childrenDelegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            int messageIndex = model.messages.length - index - 1;
            Message currentMessage = model.messages[messageIndex];

            if (currentMessage is UserMessage) {
              return ItemUserMessage(
                model: model,
                message: currentMessage,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is StatusMessage) {
              return ItemStatusMessage(
                message: currentMessage,
                textFontSize: model.textFontSize,
                iconSize: model.iconSize,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is BroadcastMessage) {
              return ItemBroadcastMessage(
                message: currentMessage,
                textFontSize: model.textFontSize,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is ComboMessage) {
              return ItemComboMessage(
                message: currentMessage,
                textFontSize: model.textFontSize,
                emoteHeight: model.emoteHeight,
                key: ValueKey<int>(messageIndex),
              );
            } else {
              return Text(
                "UNSUPPORTED MESSAGE TYPE",
                style: TextStyle(color: Colors.red),
                key: ValueKey<int>(messageIndex),
              );
            }
          },
          childCount: model.messages.length,
          findChildIndexCallback: (Key key) {
            final ValueKey valueKey = key as ValueKey<int>;
            return model.messages.length - valueKey.value - 1 as int?;
          },
        ),
      ),
    );
  }
}
