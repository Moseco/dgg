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
    required this.model,
    required this.message,
    required this.flairEnabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => model.onUserMessageLongPress(message),
      onTap: model.disableHighlightUser,
      child: Opacity(
        opacity: _getOpacity(),
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
    if (message.rainbowColor) {
      // Rainbow name
      textSpans.addAll([
        WidgetSpan(
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(colors: [
              Color.fromRGBO(255, 0, 0, 1),
              Color.fromRGBO(255, 154, 0, 1),
              Color.fromRGBO(208, 222, 33, 1),
              Color.fromRGBO(79, 220, 74, 1),
              Color.fromRGBO(63, 218, 216, 1),
              Color.fromRGBO(47, 201, 226, 1),
              Color.fromRGBO(28, 127, 238, 1),
              Color.fromRGBO(95, 21, 242, 1),
              Color.fromRGBO(186, 12, 248, 1),
              Color.fromRGBO(251, 7, 217, 1),
              Color.fromRGBO(255, 0, 0, 1),
            ]).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: GestureDetector(
              child: Text(
                message.user.nick,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: model.textFontSize,
                ),
              ),
              onTap: () => model.enableHighlightUser(message.user),
            ),
          ),
        ),
        const TextSpan(text: ": ", style: TextStyle(fontSize: 16)),
      ]);
    } else {
      // Regular name color
      textSpans.addAll([
        TextSpan(
          text: message.user.nick,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: message.color == null ? null : Color(message.color!),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => model.enableHighlightUser(message.user),
        ),
        const TextSpan(text: ": ", style: TextStyle(fontSize: 16)),
      ]);
    }

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
                ..onTap = () => model.setEmbedFromStringType(
                    element.embedId, element.embedType),
            ),
          );
        } else if (element is MentionElement) {
          textSpans.add(
            TextSpan(
              text: element.text,
              style: const TextStyle(decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()
                ..onTap = () => model.enableHighlightUser(element.user),
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

  double _getOpacity() {
    if (model.isHighlightOn &&
        message.user.nick != model.userHighlighted!.nick &&
        !_isUserMentioned()) {
      return 0.4;
    }
    return 1.0;
  }

  bool _isUserMentioned() {
    for (var i = 0; i < message.elements.length; i++) {
      if (message.elements[i] is MentionElement &&
          (message.elements[i] as MentionElement).user.nick ==
              model.userHighlighted!.nick) {
        return true;
      }
    }
    return false;
  }
}
