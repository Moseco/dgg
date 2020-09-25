import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_viewmodel.dart';
import 'widgets/widgets.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
        ),
        body: SafeArea(
          child:
              model.isAssetsLoaded ? _buildChat(model) : _buildLoading(model),
        ),
      ),
    );
  }

  Widget _buildLoading(ChatViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text("Loading assets"),
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildChat(ChatViewModel model) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: model.messages.length,
            itemBuilder: (context, index) {
              Message currentMessage =
                  model.messages[model.messages.length - index - 1];

              if (currentMessage is UserMessage) {
                return ItemUserMessage(message: currentMessage);
              } else if (currentMessage is StatusMessage) {
                return ItemStatusMessage(message: currentMessage);
              } else if (currentMessage is BroadcastMessage) {
                return ItemBroadcastMessage(message: currentMessage);
              } else {
                return Text("OTHER");
              }
            },
          ),
        ),
      ],
    );
  }
}
