import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_viewmodel.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: _buildBody(model),
        ),
      ),
    );
  }

  Widget _buildBody(ChatViewModel model) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: model.messages.length,
            itemBuilder: (context, index) {
              Message currentMessage =
                  model.messages[model.messages.length - index - 1];

              if (currentMessage is UserMessage) {
                return Text(
                    "${currentMessage.user.nick}: ${currentMessage.data}");
              } else if (currentMessage is StatusMessage) {
                return Text(currentMessage.data);
              } else {
                return Text("OTHER");
              }
            },
          ),
        )
      ],
    );
  }
}
