import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'ignore_list_viewmodel.dart';

class IgnoreListView extends StatelessWidget {
  const IgnoreListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<IgnoreListViewModel>.reactive(
      viewModelBuilder: () => IgnoreListViewModel(),
      onModelReady: (viewModel) => viewModel.initialize(),
      fireOnModelReadyOnce: true,
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: const Text("Ignore List"),
          actions: [
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: viewModel.openHelp,
            )
          ],
        ),
        body: viewModel.ignoreList == null
            ? Container()
            : viewModel.ignoreList!.isEmpty
                ? const Center(
                    child: Text(
                      "No users are being ignored.",
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: viewModel.ignoreList!.length,
                    itemBuilder: (context, index) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(viewModel.ignoreList![index]),
                      trailing: const Icon(Icons.close),
                      onTap: () => viewModel.removeFromIgnoreList(index),
                    ),
                  ),
      ),
    );
  }
}
