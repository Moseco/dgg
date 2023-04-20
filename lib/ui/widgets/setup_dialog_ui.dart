import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/embeds.dart';
import 'package:dgg/ui/views/chat/chat_viewmodel.dart' show EmbedType;
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.INPUT: (context, sheetRequest, completer) =>
        _InputDialog(request: sheetRequest, completer: completer),
    DialogType.SELECT_OPTION_FUTURE: (context, sheetRequest, completer) =>
        _SelectOptionFutureDialog(request: sheetRequest, completer: completer),
    DialogType.PLATFORM_SELECT: (context, sheetRequest, completer) =>
        _PlatformSelectDialog(request: sheetRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}

// ignore: must_be_immutable
class _InputDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;
  String input = '';

  _InputDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 20,
          right: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  request.title!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  request.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: "Channel name"),
                onChanged: (value) {
                  input = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                    onPressed: () => completer(DialogResponse()),
                  ),
                  TextButton(
                    child: const Text("Ok", style: TextStyle(fontSize: 16)),
                    onPressed: () => completer(DialogResponse(data: input)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectOptionFutureDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const _SelectOptionFutureDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 20,
          right: 20,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                request.title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: request.data!,
              builder: (context, AsyncSnapshot<List<Embed>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Text("No embeds available.");
                  } else {
                    return Flexible(
                      fit: FlexFit.loose,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final current = snapshot.data![index];
                          return ListTile(
                            title: Text(
                              "${current.link} (${current.count} embeds)",
                            ),
                            onTap: () =>
                                completer(DialogResponse(data: current)),
                          );
                        },
                      ),
                    );
                  }
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                onPressed: () => completer(DialogResponse()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformSelectDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const _PlatformSelectDialog({
    required this.request,
    required this.completer,
    Key? key,
  }) : super(key: key);

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

enum DialogType {
  INPUT,
  SELECT_OPTION_FUTURE,
  PLATFORM_SELECT,
}
