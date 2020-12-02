import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_viewmodel.dart';
import 'widgets/widgets.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          actions: model.isAssetsLoaded
              ? <Widget>[
                  PopupMenuButton<String>(
                    onSelected: model.menuItemClick,
                    itemBuilder: (BuildContext context) {
                      return {
                        'Disconnect',
                        'Reconnect',
                        "Refresh assets",
                      }.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  ),
                ]
              : null,
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
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                if (_scrollController.offset <=
                        _scrollController.position.minScrollExtent &&
                    !_scrollController.position.outOfRange) {
                  model.toggleChat(true);
                } else {
                  model.toggleChat(false);
                }
              }
              return true;
            },
            child: ListView.builder(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              controller: _scrollController,
              itemCount: model.messages.length,
              itemBuilder: (context, index) {
                int messageIndex = model.messages.length - index - 1;
                Message currentMessage = model.messages[messageIndex];

                if (currentMessage is UserMessage) {
                  return ItemUserMessage(
                    model: model,
                    message: currentMessage,
                    messageIndex: messageIndex,
                  );
                } else if (currentMessage is StatusMessage) {
                  return ItemStatusMessage(message: currentMessage);
                } else if (currentMessage is BroadcastMessage) {
                  return ItemBroadcastMessage(message: currentMessage);
                } else if (currentMessage is ComboMessage) {
                  return ItemComboMessage(message: currentMessage);
                } else {
                  return Text(
                    "UNSUPPORTED MESSAGE TYPE",
                    style: TextStyle(color: Colors.red),
                  );
                }
              },
            ),
          ),
        ),
        model.isListAtBottom ? Container() : _buildResumeChat(),
        ChatInput(model: model),
      ],
    );
  }

  Widget _buildResumeChat() {
    return InkWell(
      onTap: () => _scrollController.animateTo(
        0.0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 200),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red,
        child: Center(
          child: Text(
            "Chat paused, tap here to resume",
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
