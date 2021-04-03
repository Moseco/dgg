import 'package:flutter/material.dart';
import 'package:dgg/datamodels/emotes.dart';

class EmoteWidget extends StatelessWidget {
  final Emote emote;

  EmoteWidget({
    Key key,
    @required this.emote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (emote.image == null) {
      return SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(),
      );
    } else {
      if (emote.animated) {
        return _AnimatedEmote(emote: emote);
      } else {
        return Container(
          height: 30,
          child: emote.image,
        );
      }
    }
  }
}

class _AnimatedEmote extends StatefulWidget {
  final Emote emote;

  const _AnimatedEmote({Key key, this.emote}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedEmoteState();
}

class _AnimatedEmoteState extends State<_AnimatedEmote>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.emote.duration * widget.emote.repeatCount,
      ),
    );
    _animation = IntTween(
      begin: 0,
      end: widget.emote.frames.length * widget.emote.repeatCount,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          height: 30,
          child: widget
              .emote.frames[_animation.value % widget.emote.frames.length],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
