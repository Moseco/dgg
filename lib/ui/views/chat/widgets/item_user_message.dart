import 'dart:io' show Platform;

import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/ui/views/chat/chat_viewmodel.dart';
import 'package:dgg/ui/views/chat/widgets/emote_widget.dart';
import 'package:dgg/ui/views/chat/widgets/flair_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemUserMessage extends StatefulWidget {
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
  ItemUserMessageState createState() => ItemUserMessageState();
}

class ItemUserMessageState extends State<ItemUserMessage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => widget.model.onUserMessageLongPress(widget.message),
      onTap: () => widget.model.disableHighlightUser(),
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
              style: TextStyle(fontSize: widget.model.textFontSize),
              children: getMessageTextSpans(context),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getBackgroundColor() {
    if (widget.message.isMentioned) {
      return const Color(0xBF06263E);
    } else if (widget.message.isOwn) {
      return const Color(0x409e9e9e);
    } else {
      return null;
    }
  }

  List<InlineSpan> getMessageTextSpans(BuildContext context) {
    List<InlineSpan> textSpans = [];

    // Add timestamp if enabled
    if (widget.model.timestampEnabled) {
      textSpans.add(
        TextSpan(
          text: "${DateFormat.jm().format(widget.message.timestamp)} ",
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Add flairs if enabled
    if (widget.flairEnabled) {
      for (int i = 0; i < widget.message.visibleFlairs.length; i++) {
        textSpans.add(
          WidgetSpan(
            child: Opacity(
              opacity: imageOpacity(),
              child: FlairWidget(
                flair: widget.message.visibleFlairs[i],
                flairHeight: widget.model.flairHeight,
              ),
            ),
          ),
        );
      }
    }

    // Add username and colon
    textSpans.addAll([
      TextSpan(
        text: widget.message.user.nick,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: widget.message.color == null
              ? actualColor(Colors.white)
              : actualColor(Color(widget.message.color!)),
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () => widget.model.toggleHighlightUser(widget.message.user),
      ),
      const TextSpan(text: ": ", style: TextStyle(fontSize: 16)),
    ]);

    if (widget.message.isCensored) {
      textSpans.add(
        TextSpan(
          text: "<censored>",
          style: TextStyle(color: actualColor(Colors.blue)),
          recognizer: TapGestureRecognizer()
            ..onTap = () => widget.model.uncensorMessage(widget.message),
        ),
      );
    } else {
      for (var element in widget.message.elements) {
        if (element is UrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                color: actualColor(Colors.blue),
                decoration: widget.message.isNsfw || widget.message.isNsfl
                    ? TextDecoration.underline
                    : null,
                decorationColor:
                    widget.message.isNsfw ? Colors.red : Colors.yellow,
                decorationThickness: 2,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => widget.model.openUrl(element.text),
            ),
          );
        } else if (element is EmoteElement) {
          textSpans.add(
            WidgetSpan(
              child: Opacity(
                opacity: imageOpacity(),
                child: EmoteWidget(
                  emote: element.emote,
                  emoteHeight: widget.model.emoteHeight,
                ),
              ),
            ),
          );
        } else if (element is EmbedUrlElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(color: actualColor(Colors.blue)),
              recognizer: TapGestureRecognizer()
                ..onTap = () =>
                    widget.model.setEmbed(element.embedId, element.embedType),
            ),
          );
        } else if (element is MentionElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                color: widget.message.isGreenText
                    ? actualColor(const Color(0xFF6CA528))
                    : actualColor(Colors.white),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => widget.model.toggleHighlightUser(element.user),
            ),
          );
        } else {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: TextStyle(
                color: widget.message.isGreenText
                    ? actualColor(const Color(0xFF6CA528))
                    : actualColor(Colors.white),
              ),
            ),
          );
        }
      }
    }
    return textSpans;
  }

  bool nickIsContained() {
    for (var i = 0; i < widget.message.elements.length; i++) {
      if (widget.message.elements[i] is MentionElement &&
          (widget.message.elements[i] as MentionElement).user.nick ==
              widget.model.userHighlighted!.nick) {
        return true;
      }
    }
    return false;
  }

  Color actualColor(Color color) {
    if (widget.model.isHighlightOn &&
        widget.message.user.nick != widget.model.userHighlighted!.nick &&
        !nickIsContained()) return color.withOpacity(0.4);
    return color;
  }

  double imageOpacity() {
    if (widget.model.isHighlightOn &&
        widget.message.user.nick != widget.model.userHighlighted!.nick &&
        !nickIsContained()) return 0.4;
    return 1.0;
  }
}
