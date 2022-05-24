import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/embeds.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUi() {
  final dialogService = locator<DialogService>();

  final builders = {
    DialogType.INPUT: (context, sheetRequest, completer) =>
        _InputDialog(request: sheetRequest, completer: completer),
    DialogType.SELECT_OPTION_FUTURE: (context, sheetRequest, completer) =>
        _SelectOptionFutureDialog(request: sheetRequest, completer: completer),
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

enum DialogType {
  INPUT,
  SELECT_OPTION_FUTURE,
}
