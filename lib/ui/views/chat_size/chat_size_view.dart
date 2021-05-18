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
        appBar: AppBar(title: Text("Chat Size")),
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
                                TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ": "),
                                TextSpan(text: " This is a message"),
                                WidgetSpan(
                                  child: Container(
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
                                TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ": "),
                                TextSpan(text: " This is a wide emote"),
                                WidgetSpan(
                                  child: Container(
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
                                TextSpan(
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
                                TextSpan(
                                  text: "Name",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ": "),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/godstiny.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
                                    height: viewModel.emoteHeight,
                                    child: Image.asset(
                                      "assets/images/gameofthrows.png",
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                                TextSpan(text: " This is emote spam "),
                                WidgetSpan(
                                  child: Container(
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
              Divider(color: Colors.white54),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      "Customize text and emote size",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "Use the sliders below and see what it will look like above.",
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text("Text size"),
                              Slider(
                                min: 0,
                                max: 2,
                                divisions: 2,
                                value: viewModel.textSize,
                                label: viewModel.textSizeLabel,
                                onChanged: viewModel.updateTextSize,
                              ),
                              Text("Emote size"),
                              Slider(
                                min: 0,
                                max: 2,
                                divisions: 2,
                                value: viewModel.emoteSize,
                                label: viewModel.emoteSizeLabel,
                                onChanged: viewModel.updateEmoteSize,
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
