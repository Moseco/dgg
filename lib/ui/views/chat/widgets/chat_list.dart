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
  Widget build(BuildContext context, ChatViewModel viewModel) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          if (scrollController.offset <=
                  scrollController.position.minScrollExtent &&
              !scrollController.position.outOfRange) {
            viewModel.toggleChat(true);
          } else {
            viewModel.toggleChat(false);
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
            int messageIndex = viewModel.messages.length - index - 1;
            Message currentMessage = viewModel.messages[messageIndex];

            if (currentMessage is UserMessage) {
              return ItemUserMessage(
                model: viewModel,
                message: currentMessage,
                flairEnabled: viewModel.flairEnabled,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is StatusMessage) {
              return ItemStatusMessage(
                message: currentMessage,
                textFontSize: viewModel.textFontSize,
                iconSize: viewModel.iconSize,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is BroadcastMessage) {
              return ItemBroadcastMessage(
                message: currentMessage,
                textFontSize: viewModel.textFontSize,
                key: ValueKey<int>(messageIndex),
              );
            } else if (currentMessage is ComboMessage) {
              return ItemComboMessage(
                message: currentMessage,
                textFontSize: viewModel.textFontSize,
                emoteHeight: viewModel.emoteHeight,
                key: ValueKey<int>(messageIndex),
              );
            } else {
              return Text(
                "UNSUPPORTED MESSAGE TYPE",
                style: const TextStyle(color: Colors.red),
                key: ValueKey<int>(messageIndex),
              );
            }
          },
          childCount: viewModel.messages.length,
          findChildIndexCallback: (Key key) {
            final ValueKey valueKey = key as ValueKey<int>;
            return viewModel.messages.length - valueKey.value - 1 as int?;
          },
        ),
      ),
    );
  }
}
