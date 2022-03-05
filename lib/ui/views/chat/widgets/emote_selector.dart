import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../chat_viewmodel.dart';

class EmoteSelector extends ViewModelWidget<ChatViewModel> {
  const EmoteSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ChatViewModel viewModel) {
    return WillPopScope(
      onWillPop: () async {
        viewModel.toggleEmoteSelector();
        return false;
      },
      child: Container(
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          top: 8,
          bottom: viewModel.draft.isEmpty ? 75 : 110,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(
                viewModel.emoteSelectorList!.length,
                (index) => GestureDetector(
                  child: EmoteWidget(
                    emote: viewModel.emoteSelectorList![index],
                    emoteHeight: viewModel.emoteHeight,
                  ),
                  onTap: () => viewModel.emoteSelected(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
