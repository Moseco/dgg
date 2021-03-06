import 'dart:io' show Platform;

import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemUserMessage extends StatelessWidget {
  final ChatViewModel model;
  final UserMessage message;

  const ItemUserMessage({
    Key key,
    this.model,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _onLongPress(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: _getBackgroundColor(),
        child: RichText(
          text: TextSpan(
            children: getMessageTextSpans(context),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (message.isMentioned) {
      return Color(0xBF06263E);
    } else if (message.isOwn) {
      return Color(0x409e9e9e); //0x80151515
    } else {
      return null;
    }
  }

  List<InlineSpan> getMessageTextSpans(BuildContext context) {
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

    if (message.isCensored) {
      textSpans.add(
        TextSpan(
          text: "<censored>",
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => model.uncensorMessage(message),
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
              child: EmoteWidget(emote: element.emote),
            ),
          );
        } else if (element is EmbedUrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
              recognizer: Platform.isAndroid
                  ? (TapGestureRecognizer()
                    ..onTap = () => model.setStreamChannel(
                        element.embedId, element.embedType))
                  : null,
              //There is a problem with using a GestureRecognizer on a TextSpan if there is a WidgetSpan with it
              //  Problem only happens on iOS so need different approach on Android/iOS
              //  https://github.com/flutter/flutter/issues/51936
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
