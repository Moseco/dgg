import 'package:dgg/datamodels/embeds.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

class SelectEmbedDialog extends StatelessWidget {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const SelectEmbedDialog({
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
            Text(
              request.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder(
              future: request.data!,
              builder: (context, AsyncSnapshot<List<Embed>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Text('No embeds available');
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
                              '${current.link} (${current.count} embeds)',
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
          ],
        ),
      ),
    );
  }
}
