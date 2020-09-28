import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/ui/chat/chat_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemUserMessage extends ViewModelWidget<ChatViewModel> {
  final UserMessage message;
  final int messageIndex;

  const ItemUserMessage({
    Key key,
    this.message,
    this.messageIndex,
  }) : super(key: key, reactive: true);

  @override
  Widget build(BuildContext context, ChatViewModel model) {
    return GestureDetector(
      onLongPress: () => _onLongPress(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            children: getMessageTextSpans(context, model),
          ),
        ),
      ),
    );
  }

  List<InlineSpan> getMessageTextSpans(
      BuildContext context, ChatViewModel model) {
    List<InlineSpan> textSpans = [
      TextSpan(
        text: message.user.nick,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: message.color == null ? null : Color(message.color),
        ),
      ),
      TextSpan(
        text: ": ",
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ];

    if (message.censored) {
      textSpans.add(
        TextSpan(
          text: "<censored>",
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => model.uncensorMessage(messageIndex),
        ),
      );
    } else {
      message.elements.forEach((element) {
        if (element is UrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
              recognizer: Platform.isAndroid
                  ? (TapGestureRecognizer()
                    ..onTap = () => _openUrl(context, element.text))
                  : null,
              //There is a problem with using a GestureRecognizer on a TextSpan if there is a WidgetSpan with it
              //  Problem only happens on iOS so need different approach on Android/iOS
              //  https://github.com/flutter/flutter/issues/51936
            ),
          );
        } else if (element is EmoteElement) {
          textSpans.add(
            WidgetSpan(
              child: CachedNetworkImage(
                imageUrl: element.url,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 30,
              ),
            ),
          );
        } else {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          );
        }
      });
    }
    return textSpans;
  }

  _onLongPress(BuildContext context) {
    //Copy message text to clipboard
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text("Message copied to clipboard"),
      ),
    );
    Clipboard.setData(ClipboardData(text: message.data));
  }

  _openUrl(BuildContext context, String url) async {
    String urlToOpen = url;
    if (!url.startsWith("http")) {
      urlToOpen = "http://" + url;
    }

    if (await canLaunch(urlToOpen)) {
      launch(urlToOpen);
    } else {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not open. Url copied to clipboard"),
          backgroundColor: Colors.red,
        ),
      );
      Clipboard.setData(ClipboardData(text: url));
    }
  }
}
