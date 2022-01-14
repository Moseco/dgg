import 'dart:io' show Platform;

import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:dgg/ui/views/chat/widgets/flair_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemUserMessage extends StatelessWidget {
  final ChatViewModel model;
  final UserMessage message;
  final bool flairEnabled;

  const ItemUserMessage({
    Key? key,
    required this.model,
    required this.message,
    required this.flairEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => model.onUserMessageLongPress(message),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        color: _getBackgroundColor(),
        child: ExcludeSemantics(
          // There is a problem with using a GestureRecognizer on a TextSpan if there is a WidgetSpan with it
          //    Problem only happens on iOS so need different approach on Android/iOS
          //    https://github.com/flutter/flutter/issues/51936
          excluding: Platform.isIOS,
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: model.textFontSize),
              children: getMessageTextSpans(context),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor() {
    if (message.isMentioned) {
      return const Color(0xBF06263E);
    } else if (message.isOwn) {
      return const Color(0x409e9e9e);
    } else {
      return null;
    }
  }

  List<InlineSpan> getMessageTextSpans(BuildContext context) {
    List<InlineSpan> textSpans = [];

    // Add timestamp if enabled
    if (model.timestampEnabled) {
      textSpans.add(
        TextSpan(
          text: "${DateFormat.jm().format(message.timestamp)} ",
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Add flairs if enabled
    if (flairEnabled) {
      for (int i = 0; i < message.visibleFlairs.length; i++) {
        textSpans.add(
          WidgetSpan(
            child: FlairWidget(
              flair: message.visibleFlairs[i],
              flairHeight: model.flairHeight,
            ),
          ),
        );
      }
    }

    // Add username and colon
    textSpans.addAll([
      TextSpan(
        text: message.user.nick,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: message.color == null ? null : Color(message.color!),
        ),
      ),
      const TextSpan(text: ": ", style: TextStyle(fontSize: 16)),
    ]);

    if (message.isCensored) {
      textSpans.add(
        TextSpan(
          text: "<censored>",
          style: const TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () => model.uncensorMessage(message),
        ),
      );
    } else {
      for (var element in message.elements) {
        if (element is UrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                color: Colors.blue,
                decoration: message.isNsfw || message.isNsfl
                    ? TextDecoration.underline
                    : null,
                decorationColor: message.isNsfw ? Colors.red : Colors.yellow,
                decorationThickness: 2,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => model.openUrl(element.text),
            ),
          );
        } else if (element is EmoteElement) {
          textSpans.add(
            WidgetSpan(
              child: EmoteWidget(
                emote: element.emote,
                emoteHeight: model.emoteHeight,
              ),
            ),
          );
        } else if (element is EmbedUrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap =
                    () => model.setEmbed(element.embedId, element.embedType),
            ),
          );
        } else {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                color: message.isGreenText ? const Color(0xFF6CA528) : null,
              ),
            ),
          );
        }
      }
    }
    return textSpans;
  }
}
