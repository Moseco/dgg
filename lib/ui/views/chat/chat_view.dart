import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dgg/ui/views/chat/widgets/emote_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:stacked/stacked.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
    as extended_nested_scroll_view;
import 'package:stacked_hooks/stacked_hooks.dart';
import 'chat_viewmodel.dart';
import 'widgets/widgets.dart';

class ChatView extends StatelessWidget {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket();

  ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) => OrientationBuilder(
        builder: (_, orientation) => Scaffold(
          appBar: AppBar(
            title: const Text("Chat"),
            backgroundColor:
                viewModel.appBarTheme == 1 ? Colors.transparent : null,
            elevation: viewModel.appBarTheme == 1 ? 0 : null,
            actions: viewModel.isAssetsLoaded
                ? <Widget>[
                    IconButton(
                      icon: viewModel.showEmbed
                          ? const Icon(Icons.desktop_access_disabled)
                          : const Icon(Icons.desktop_windows),
                      onPressed: () =>
                          viewModel.setShowEmbed(!viewModel.showEmbed),
                    ),
                    PopupMenuButton<AppBarActions>(
                      onSelected: (AppBarActions selected) =>
                          selected == AppBarActions.OPEN_TWITCH_STREAM
                              ? showStreamSelectDialog(context, viewModel)
                              : viewModel.menuItemClick(selected),
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<AppBarActions>(
                            value: AppBarActions.SETTINGS,
                            child: Text('Settings'),
                          ),
                          PopupMenuItem<AppBarActions>(
                            value: AppBarActions.CONNECTION,
                            child: Text(
                              viewModel.isChatConnected
                                  ? 'Disconnect'
                                  : 'Reconnect',
                            ),
                          ),
                          const PopupMenuItem<AppBarActions>(
                            value: AppBarActions.REFRESH,
                            child: Text('Refresh emotes'),
                          ),
                          const PopupMenuItem<AppBarActions>(
                            value: AppBarActions.OPEN_DESTINY_STREAM,
                            child: Text('Open Destiny\'s steam'),
                          ),
                          const PopupMenuItem<AppBarActions>(
                            value: AppBarActions.OPEN_TWITCH_STREAM,
                            child: Text('Set Twitch stream'),
                          ),
                        ];
                      },
                    ),
                  ]
                : null,
          ),
          body: PageStorage(
            bucket: _pageStorageBucket,
            child: SafeArea(
              child: viewModel.isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(),
                          ),
                          Text(
                            viewModel.isAuthenticating
                                ? "Authenticating with dgg"
                                : "Loading assets",
                          ),
                        ],
                      ),
                    )
                  : orientation == Orientation.portrait
                      ? const _ChatPortrait()
                      : const _ChatLandscape(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showStreamSelectDialog(
    BuildContext context,
    ChatViewModel viewModel,
  ) async {
    // Show dialog and get result
    final result = await showTextInputDialog(
      context: context,
      title: "Open Twitch stream",
      message: "Enter the name of the Twitch stream you want to open",
      textFields: const [
        DialogTextField(hintText: "Channel name"),
      ],
    );

    viewModel.setStreamChannelManual(result);
  }
}

class _ChatPortrait extends HookViewModelWidget<ChatViewModel> {
  const _ChatPortrait({Key? key}) : super(key: key);

  @override
  Widget buildViewModelWidget(BuildContext context, ChatViewModel viewModel) {
    final scrollController = useScrollController();
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: extended_nested_scroll_view.NestedScrollView(
                headerSliverBuilder: (
                  BuildContext context,
                  bool? innerBoxIsScrolled,
                ) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ChatStreamEmbed(),
                          if (viewModel.currentVote != null)
                            ChatVote(model: viewModel),
                        ],
                      ),
                    ),
                  ];
                },
                pinnedHeaderSliverHeightBuilder: () => kToolbarHeight,
                body: ChatList(
                  key: const PageStorageKey("chatlist"),
                  scrollController: scrollController,
                ),
              ),
            ),
            if (!viewModel.isListAtBottom)
              InkWell(
                onTap: () => scrollController.animateTo(
                  0.0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 200),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red,
                  child: const Center(
                    child: Text(
                      "Chat paused, tap here to resume",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            if (viewModel.showReconnectButton)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Reconnect"),
                onPressed: () => viewModel.onReconnectButtonPressed(),
              ),
            ChatInput(model: viewModel),
          ],
        ),
        if (viewModel.showEmoteSelector) const EmoteSelector(),
      ],
    );
  }
}

class _ChatLandscape extends HookViewModelWidget<ChatViewModel> {
  const _ChatLandscape({Key? key}) : super(key: key);

  @override
  Widget buildViewModelWidget(BuildContext context, ChatViewModel viewModel) {
    final scrollController = useScrollController();
    return Row(
      children: [
        if (viewModel.showStreamPrompt || viewModel.showEmbed)
          const Expanded(child: ChatStreamEmbed()),
        Expanded(
          child: Column(
            children: [
              if (viewModel.currentVote != null)
                Flexible(
                  child: SingleChildScrollView(
                    child: ChatVote(model: viewModel),
                  ),
                ),
              Expanded(
                child: ChatList(
                  key: const PageStorageKey("chatlist"),
                  scrollController: scrollController,
                ),
              ),
              if (!viewModel.isListAtBottom)
                InkWell(
                  onTap: () => scrollController.animateTo(
                    0.0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 200),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        "Chat paused, tap here to resume",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              if (viewModel.showReconnectButton)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Reconnect"),
                  onPressed: () => viewModel.onReconnectButtonPressed(),
                ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                  ),
                ),
                child: const Center(
                  child: Text(
                    "Input unavailable in landscape",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
