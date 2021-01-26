import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extendedNestedScrollView;

import 'chat_viewmodel.dart';
import 'widgets/widgets.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  ScrollController _scrollController;

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
          actions: model.isAssetsLoaded
              ? <Widget>[
                  IconButton(
                    icon: model.showStreamEmbed
                        ? Icon(Icons.desktop_access_disabled)
                        : Icon(Icons.desktop_windows),
                    onPressed: () =>
                        model.setShowStreamEmbed(!model.showStreamEmbed),
                  ),
                  PopupMenuButton<int>(
                    onSelected: (int selected) => selected == 3
                        ? showStreamSelectDialog(model)
                        : model.menuItemClick(selected),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<int>(value: 0, child: Text('Disconnect')),
                        PopupMenuItem<int>(value: 1, child: Text('Reconnect')),
                        PopupMenuItem<int>(
                            value: 2, child: Text('Refresh assets')),
                        PopupMenuItem<int>(value: 3, child: Text('Set stream')),
                      ];
                    },
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child:
              model.isAssetsLoaded ? _buildLoaded(model) : _buildLoading(model),
        ),
      ),
    );
  }

  Widget _buildLoading(ChatViewModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text("Loading assets"),
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildLoaded(ChatViewModel model) {
    return Column(
      children: [
        _buildContent(model),
        model.isListAtBottom ? Container() : _buildResumeChat(),
        ChatInput(model: model),
      ],
    );
  }

  Widget _buildContent(ChatViewModel model) {
    return Expanded(
      child: extendedNestedScrollView.NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStreamEmbed(model),
                  model.currentVote == null
                      ? Container()
                      : ChatVote(model: model),
                ],
              ),
            ),
          ];
        },
        pinnedHeaderSliverHeightBuilder: () => kToolbarHeight,
        body: _buildChat(model),
      ),
    );
  }

  Widget _buildStreamEmbed(ChatViewModel model) {
    if (model.showStreamPrompt) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text("Destiny is live. Show the stream?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: RaisedButton(
                    child: Text("Yes"),
                    onPressed: () => model.setShowStreamEmbed(true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: RaisedButton(
                    child: Text("No"),
                    onPressed: () => model.setShowStreamEmbed(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      if (model.showStreamEmbed) {
        return Container(
          height: 9 / 16 * MediaQuery.of(context).size.width,
          child: WebView(
            initialUrl: model.twitchUrlBase + model.currentStreamChannel,
            javascriptMode: JavascriptMode.unrestricted,
            initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
            onWebViewCreated: (WebViewController webViewController) {
              model.webViewController = webViewController;
            },
          ),
        );
      } else {
        return Container();
      }
    }
  }

  Widget _buildChat(ChatViewModel model) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollEndNotification) {
          if (_scrollController.offset <=
                  _scrollController.position.minScrollExtent &&
              !_scrollController.position.outOfRange) {
            model.toggleChat(true);
          } else {
            model.toggleChat(false);
          }
        }
        return true;
      },
      child: ListView.builder(
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        controller: _scrollController,
        itemCount: model.messages.length,
        itemBuilder: (context, index) {
          int messageIndex = model.messages.length - index - 1;
          Message currentMessage = model.messages[messageIndex];

          if (currentMessage is UserMessage) {
            return ItemUserMessage(
              model: model,
              message: currentMessage,
            );
          } else if (currentMessage is StatusMessage) {
            return ItemStatusMessage(message: currentMessage);
          } else if (currentMessage is BroadcastMessage) {
            return ItemBroadcastMessage(message: currentMessage);
          } else if (currentMessage is ComboMessage) {
            return ItemComboMessage(message: currentMessage);
          } else {
            return Text(
              "UNSUPPORTED MESSAGE TYPE",
              style: TextStyle(color: Colors.red),
            );
          }
        },
      ),
    );
  }

  Widget _buildResumeChat() {
    return InkWell(
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

    model.setStreamChannel(result);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
