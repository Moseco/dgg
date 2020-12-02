import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final ChatViewModel model;

  const ChatInput({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.model.isSignedIn) {
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
    if (widget.model.draft.isEmpty) {
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
          itemCount: widget.model.suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                _textEditingController.text =
                    widget.model.completeSuggestion(index);
                _textEditingController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _textEditingController.text.length));
              },
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(widget.model.suggestions[index]),
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
      controller: _textEditingController,
      minLines: 1,
      maxLines: 3,
      onChanged: widget.model.updateChatDraft,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Type a message...',
        suffixIcon: IconButton(
          icon: Icon(Icons.send),
          onPressed:
              widget.model.isChatConnected && widget.model.draft.isNotEmpty
                  ? () {
                      if (widget.model.sendChatMessage()) {
                        _textEditingController.clear();
                      }
                    }
                  : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
