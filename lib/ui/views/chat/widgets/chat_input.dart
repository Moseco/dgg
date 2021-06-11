import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  final ChatViewModel model;

  const ChatInput({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (model.isSignedIn) {
      return _buildInput(context);
    } else {
      return _buildNoInput();
    }
  }

  Widget _buildNoInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(),
        ),
      ),
      child: Center(
        child: Text(
          "Must be signed in to chat",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          _buildSuggestionList(context),
          _buildTextField(context),
        ],
      ),
    );
  }

  Widget _buildSuggestionList(BuildContext context) {
    if (model.draft.isEmpty) {
      return Container();
    } else {
      return Container(
        height: 40,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(),
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () => model.completeSuggestion(index),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(model.suggestions[index]),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget _buildTextField(BuildContext context) {
    return TextField(
      controller: model.chatInputController,
      minLines: 1,
      maxLines: 3,
      onChanged: model.updateChatDraft,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.send,
      onSubmitted: (_) => model.sendChatMessage(),
      onEditingComplete: () {},
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Type a message...',
        suffixIcon: IconButton(
          icon: Icon(Icons.send),
          onPressed: model.isChatConnected && model.draft.isNotEmpty
              ? () => model.sendChatMessage()
              : null,
        ),
      ),
    );
  }
}
