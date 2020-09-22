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
  final String url;

  const EmoteElement(
    String text,
    this.url,
  ) : super(text);
}
