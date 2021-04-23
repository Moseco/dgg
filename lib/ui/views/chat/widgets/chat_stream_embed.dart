import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../chat_viewmodel.dart';

class ChatStreamEmbed extends ViewModelWidget<ChatViewModel> {
  @override
  Widget build(BuildContext context, ChatViewModel model) {
    if (model.showStreamPrompt) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text("Destiny is live. Show the stream?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ElevatedButton(
                    child: Text("Yes"),
                    onPressed: () => model.setShowEmbed(true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: ElevatedButton(
                    child: Text("No"),
                    onPressed: () => model.setShowEmbed(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      if (model.showEmbed) {
        if (model.embedType == EmbedType.YOUTUBE) {
          // Show youtube
          return YoutubePlayerIFrame(
            controller: model.youtubePlayerController,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
          );
        } else {
          // Show webview and display correct twitch page
          return Container(
            height: 9 / 16 * MediaQuery.of(context).size.width,
            child: WebView(
              initialUrl: model.getTwitchEmbedUrl(),
              javascriptMode: JavascriptMode.unrestricted,
              initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
              onWebViewCreated: (WebViewController webViewController) {
                model.webViewController = webViewController;
              },
            ),
          );
        }
      } else {
        return Container();
      }
    }
  }
}
