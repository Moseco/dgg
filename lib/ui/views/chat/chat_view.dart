import 'package:dgg/ui/views/chat/widgets/chat_embed_prompt.dart';
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

  ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatViewModel>.reactive(
      viewModelBuilder: () => ChatViewModel(),
      fireOnModelReadyOnce: true,
      onModelReady: (viewModel) => viewModel.initialize(),
      builder: (context, viewModel, child) => OrientationBuilder(
        builder: (_, orientation) => Scaffold(
          appBar: orientation == Orientation.landscape
              ? null
              : AppBar(
                  title: const Text("Dgg"),
                  backgroundColor:
                      viewModel.appBarTheme == 1 ? Colors.transparent : null,
                  elevation: viewModel.appBarTheme == 1 ? 0 : null,
                  actions: viewModel.assetsLoaded
                      ? <Widget>[
                          if (viewModel.currentEmbedType != null)
                            IconButton(
                              icon: viewModel.showEmbed
                                  ? const Icon(Icons.desktop_access_disabled)
                                  : const Icon(Icons.desktop_windows_outlined),
                              onPressed: viewModel.toggleEmbed,
                            ),
                          PopupMenuButton<AppBarActions>(
                            onSelected: viewModel.menuItemClick,
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.SETTINGS,
                                  child: Text('Settings'),
                                ),
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.REFRESH,
                                  child: Text('Reload chat'),
                                ),
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.OPEN_DESTINY_STREAM,
                                  child: Text('Open Destiny\'s stream'),
                                ),
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.OPEN_TWITCH_STREAM,
                                  child: Text('Set Twitch stream'),
                                ),
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.OPEN_KICK_STREAM,
                                  child: Text('Set Kick stream'),
                                ),
                                const PopupMenuItem<AppBarActions>(
                                  value: AppBarActions.GET_RECENT_EMBEDS,
                                  child: Text('Get recent embeds'),
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
                  : const _Chat(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Chat extends StackedHookView<ChatViewModel> {
  const _Chat();

  @override
  Widget builder(BuildContext context, ChatViewModel viewModel) {
    final scrollController = useScrollController();
    return Stack(
      children: [
        Flex(
          direction: MediaQuery.of(context).orientation == Orientation.portrait
              ? Axis.vertical
              : Axis.horizontal,
          children: [
            if (viewModel.showStreamPrompt) const ChatEmbedPrompt(),
            if (viewModel.showEmbed)
              Expanded(
                flex: MediaQuery.of(context).orientation == Orientation.portrait
                    ? 1
                    : 4,
                child: const ChatStreamEmbed(),
              ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: extended_nested_scroll_view.ExtendedNestedScrollView(
                      headerSliverBuilder: (
                        BuildContext context,
                        bool? innerBoxIsScrolled,
                      ) {
                        return <Widget>[
                          SliverToBoxAdapter(
                            child: (viewModel.currentVote != null)
                                ? ChatVote(model: viewModel)
                                : null,
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Reconnect"),
                      onPressed: () => viewModel.onReconnectButtonPressed(),
                    ),
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? ChatInput(model: viewModel)
                      : Container(
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
        ),
        if (viewModel.showEmoteSelector &&
            MediaQuery.of(context).orientation == Orientation.portrait)
          const EmoteSelector(),
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                ),
                color: Theme.of(context).colorScheme.surface == Colors.black
                    ? Colors.black
                    : Theme.of(context).primaryColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (viewModel.currentEmbedType != null)
                    IconButton(
                      icon: viewModel.showEmbed
                          ? const Icon(Icons.desktop_access_disabled)
                          : const Icon(Icons.desktop_windows_outlined),
                      onPressed: viewModel.toggleEmbed,
                    ),
                  PopupMenuButton<AppBarActions>(
                    onSelected: viewModel.menuItemClick,
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<AppBarActions>(
                          value: AppBarActions.SETTINGS,
                          child: Text('Settings'),
                        ),
                        const PopupMenuItem<AppBarActions>(
                          value: AppBarActions.REFRESH,
                          child: Text('Reload chat'),
                        ),
                        const PopupMenuItem<AppBarActions>(
                          value: AppBarActions.OPEN_DESTINY_STREAM,
                          child: Text('Open Destiny\'s steam'),
                        ),
                        const PopupMenuItem<AppBarActions>(
                          value: AppBarActions.OPEN_TWITCH_STREAM,
                          child: Text('Set Twitch stream'),
                        ),
                        const PopupMenuItem<AppBarActions>(
                          value: AppBarActions.GET_RECENT_EMBEDS,
                          child: Text('Get recent embeds'),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
