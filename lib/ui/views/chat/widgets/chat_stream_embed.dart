import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../chat_viewmodel.dart';

class ChatStreamEmbed extends ViewModelWidget<ChatViewModel> {
  const ChatStreamEmbed({super.key});

  @override
  Widget build(BuildContext context, ChatViewModel viewModel) {
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
  }
}
