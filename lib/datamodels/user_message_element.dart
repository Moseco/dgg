import 'package:dgg/datamodels/emotes.dart';

abstract class UserMessageElement {
  final String text;

  const UserMessageElement(this.text);
}

class TextElement extends UserMessageElement {
  const TextElement(
    String text,
  ) : super(text);
}

class UrlElement extends UserMessageElement {
  const UrlElement(
    String text,
  ) : super(text);
}

class EmoteElement extends UserMessageElement {
  final Emote emote;

  const EmoteElement(
    String text,
    this.emote,
  ) : super(text);
}

class EmbedUrlElement extends UserMessageElement {
  final String channel;
  const EmbedUrlElement(
    String text,
    this.channel,
  ) : super(text);
}
