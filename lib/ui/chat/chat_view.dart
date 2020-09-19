import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_viewmodel.dart';

class ChatView extends StatelessWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("Chat page"),
        ),
      ),
    );
  }
}
