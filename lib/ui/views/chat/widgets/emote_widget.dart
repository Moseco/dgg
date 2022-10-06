import 'package:flutter/material.dart';
import 'package:dgg/datamodels/emotes.dart';

class EmoteWidget extends StatelessWidget {
  final Emote emote;
  final double emoteHeight;

  const EmoteWidget({
    Key? key,
    required this.emote,
    required this.emoteHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (emote.image == null) {
      return SizedBox(
        height: emoteHeight,
        width: emoteHeight,
        child: const CircularProgressIndicator(),
      );
    } else {
      if (emote.animated) {
        return _AnimatedEmote(
          emote: emote,
          emoteHeight: emoteHeight,
        );
      } else {
        return SizedBox(
          height: emoteHeight,
          child: emote.image,
        );
      }
    }
  }
}

class _AnimatedEmote extends StatefulWidget {
  final Emote emote;
  final double emoteHeight;

  const _AnimatedEmote({
    Key? key,
    required this.emote,
    required this.emoteHeight,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimatedEmoteState();
}

class _AnimatedEmoteState extends State<_AnimatedEmote>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.emote.duration! * widget.emote.repeatCount!,
      ),
    );
    _animation = IntTween(
      begin: 0,
      end: widget.emote.frames == null ? 0 : widget.emote.frames!.length * widget.emote.repeatCount!,
    ).animate(_controller);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return SizedBox(
          height: widget.emoteHeight,
          child: widget.emote.frames != null ? widget
              .emote.frames![_animation.value % widget.emote.frames!.length] : widget.emote.image,
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
