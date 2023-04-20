import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../chat_viewmodel.dart';

class ChatStreamEmbed extends ViewModelWidget<ChatViewModel> {
  const ChatStreamEmbed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ChatViewModel viewModel) {
    if (viewModel.showStreamPrompt) {
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
    } else if (viewModel.showEmbed) {
      // TODO PROBLEM: Every time screen is rotated video is reloaded
      if (viewModel.currentEmbedType == null) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (viewModel.currentEmbedType == EmbedType.YOUTUBE) {
        // Show youtube
        return YoutubePlayerIFrame(
          controller: viewModel.youtubePlayerController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        );
      } else if (viewModel.currentEmbedType == EmbedType.KICK) {
        return SizedBox(
          height: 9 / 16 * MediaQuery.of(context).size.width,
          child: Chewie(controller: viewModel.chewieController!),
        );
      } else {
        // Show webview and display correct embed
        return SizedBox(
          height: 9 / 16 * MediaQuery.of(context).size.width,
          child: WebView(
            initialUrl: viewModel.getEmbedUrl(),
            javascriptMode: JavascriptMode.unrestricted,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            onWebViewCreated: (WebViewController webViewController) {
              viewModel.webViewController = webViewController;
            },
          ),
        );
      }
    } else {
      return Container();
    }
  }
}
