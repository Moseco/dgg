import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extendedNestedScrollView;
import 'chat_viewmodel.dart';
import 'widgets/widgets.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
          backgroundColor: model.appBarTheme == 1 ? Colors.transparent : null,
          elevation: model.appBarTheme == 1 ? 0 : null,
          actions: model.isAssetsLoaded
              ? <Widget>[
                  IconButton(
                    icon: model.showEmbed
                        ? Icon(Icons.desktop_access_disabled)
                        : Icon(Icons.desktop_windows),
                    onPressed: () => model.setShowEmbed(!model.showEmbed),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int selected) => selected == 4
                        ? showStreamSelectDialog(model)
                        : model.menuItemClick(selected),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<int>(value: 0, child: Text('Settings')),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Text(
                            model.isChatConnected ? 'Disconnect' : 'Reconnect',
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Text('Refresh emotes'),
                        ),
                        PopupMenuItem<int>(
                          value: 3,
                          child: Text('Open Destiny\'s steam'),
                        ),
                        PopupMenuItem<int>(
                          value: 4,
                          child: Text('Set Twitch stream'),
                        ),
                      ];
                    },
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child: model.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      ),
                      Text(model.isAuthenticating
                          ? "Authenticating with dgg"
                          : "Loading assets"),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: extendedNestedScrollView.NestedScrollView(
                        headerSliverBuilder:
                            (BuildContext context, bool? innerBoxIsScrolled) {
                          return <Widget>[
                            SliverToBoxAdapter(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ChatStreamEmbed(),
                                  model.currentVote == null
                                      ? Container()
                                      : ChatVote(model: model),
                                ],
                              ),
                            ),
                          ];
                        },
                        pinnedHeaderSliverHeightBuilder: () => kToolbarHeight,
                        body: ChatList(scrollController: _scrollController),
                      ),
                    ),
                    model.isListAtBottom
                        ? Container()
                        : InkWell(
                            onTap: () => _scrollController.animateTo(
                              0.0,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 200),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  "Chat paused, tap here to resume",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                    model.showReconnectButton
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text("Reconnect"),
                            onPressed: () => model.onReconnectButtonPressed(),
                          )
                        : Container(),
                    ChatInput(model: model),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> showStreamSelectDialog(ChatViewModel model) async {
    //Show dialog and get result
    final result = await showTextInputDialog(
      context: context,
      title: "Open Twitch stream",
      message: "Enter the name of the Twitch stream you want to open",
      textFields: const [
        DialogTextField(hintText: "Channel name"),
      ],
    );

    model.setStreamChannelManual(result);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
