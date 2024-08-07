import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../chat_viewmodel.dart';

class ChatEmbedPrompt extends ViewModelWidget<ChatViewModel> {
  const ChatEmbedPrompt({super.key});

  @override
  Widget build(BuildContext context, ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Text("Destiny is live. Show the stream?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: ElevatedButton(
                  child: const Text("Yes"),
                  onPressed: () => viewModel.answerInitialStreamPrompt(true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: ElevatedButton(
                  child: const Text("No"),
                  onPressed: () => viewModel.answerInitialStreamPrompt(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
