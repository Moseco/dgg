import 'package:dgg/ui/views/chat/chat_viewmodel.dart' show EmbedType;
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class SelectPlatformDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SelectPlatformDialog({
    required this.request,
    required this.completer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'Which platform do you want to embed?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            if (request.data!.twitchLive)
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Twitch'),
                onTap: () => completer(
                  DialogResponse(data: EmbedType.TWITCH_STREAM),
                ),
              ),
            if (request.data!.youtubeLive && request.data!.youtubeId != null)
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('YouTube'),
                onTap: () => completer(
                  DialogResponse(data: EmbedType.YOUTUBE),
                ),
              ),
            if (request.data!.rumbleLive && request.data!.rumbleId != null)
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Rumble'),
                onTap: () => completer(
                  DialogResponse(data: EmbedType.RUMBLE),
                ),
              ),
            if (request.data!.kickLive && request.data!.kickId != null)
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: const Text('Kick'),
                onTap: () => completer(
                  DialogResponse(data: EmbedType.KICK),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
