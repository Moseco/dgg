import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'chat_size_viewmodel.dart';

class ChatSizeView extends StatelessWidget {
  const ChatSizeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatSizeViewModel>.reactive(
      viewModelBuilder: () => ChatSizeViewModel(),
      onModelReady: (viewModel) => viewModel.initialize(),
      fireOnModelReadyOnce: true,
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text("Chat Size")),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: viewModel.textFontSize,
                              ),
                              children: [
                                WidgetSpan(
                                  child: viewModel.flairEnabled
                                      ? Container(
                                          height: viewModel.flairHeight,
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Image.asset(
                                            "assets/images/dgg_icon.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                      : Container(),
                                ),
                                const TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ": "),
                                const TextSpan(text: " This is a message"),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: viewModel.textFontSize,
                              ),
                              children: [
                                WidgetSpan(
                                  child: viewModel.flairEnabled
                                      ? Container(
                                          height: viewModel.flairHeight,
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Image.asset(
                                            "assets/images/dgg_icon.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                      : Container(),
                                ),
                                const TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ": "),
                                const TextSpan(text: " This is a wide emote"),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: viewModel.textFontSize,
                              ),
                              children: <InlineSpan>[
                                WidgetSpan(
                                  child: Icon(
                                    Icons.info_outline,
                                    size: viewModel.iconSize,
                                  ),
                                ),
                                const TextSpan(
                                  text: " This is a status message",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: viewModel.textFontSize,
                              ),
                              children: [
                                WidgetSpan(
                                  child: viewModel.flairEnabled
                                      ? Container(
                                          height: viewModel.flairHeight,
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: Image.asset(
                                            "assets/images/dgg_icon.png",
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                      : Container(),
                                ),
                                const TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ": "),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                const TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: SizedBox(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.white54),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "Customize the look of the chat",
                      style: TextStyle(fontSize: 24),
                    ),
                    const Text(
                      "Use the sliders below and see what it will look like above.",
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text("Text size"),
                              Slider(
                                min: 0,
                                max: 2,
                                divisions: 2,
                                value: viewModel.textSize,
                                label: viewModel.textSizeLabel,
                                onChanged: viewModel.updateTextSize,
                              ),
                              const Text("Emote size"),
                              Slider(
                                min: 0,
                                max: 2,
                                divisions: 2,
                                value: viewModel.emoteSize,
                                label: viewModel.emoteSizeLabel,
                                onChanged: viewModel.updateEmoteSize,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Enable flairs"),
                                  Switch(
                                    value: viewModel.flairEnabled,
                                    activeColor: Theme.of(context).primaryColor,
                                    onChanged: viewModel.updateFlairEnabled,
                                  ),
                                ],
                              ),
                              const Text("Flair size"),
                              Slider(
                                min: 0,
                                max: 2,
                                divisions: 2,
                                value: viewModel.flairSize,
                                label: viewModel.flairSizeLabel,
                                onChanged: viewModel.updateFlairSize,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
