import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/ui/widgets/delayed_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model.initialize(),
      fireOnModelReadyOnce: true,
      builder: (context, model, child) => Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Image.asset(
                      "assets/images/dgg_logo.png",
                      width: MediaQuery.of(context).size.width * 0.75,
                    ),
                  ),
                  model.sessionInfo == null
                      ? _buildLoading(context)
                      : _buildLoaded(context, model),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return DelayedWidget(
      child: Column(
        children: [
          CircularProgressIndicator(),
          Text(
            "Authenticating with destiny.gg\nPlease wait...",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      delayMilliseconds: 1000,
    );
  }

  Widget _buildLoaded(BuildContext context, HomeViewModel model) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            _buildSessionWidget(model),
            _buildLargeButton(
              "Open chat",
              Icons.chat,
              () => model.navigateToChat(),
              Theme.of(context).primaryColor,
            ),
            model.appDownloadUrl != null
                ? _buildLargeButton(
                    "Download app update",
                    Icons.cloud_download,
                    () => model.openAppDownloadUrl(),
                    Colors.red,
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionWidget(HomeViewModel model) {
    SessionInfo sessionInfo = model.sessionInfo;

    if (sessionInfo is Unauthenticated) {
      //Not signed in
      return OutlineButton(
        borderSide: BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text("Sign in"),
        onPressed: () => model.navigateToAuth(),
      );
    } else if (sessionInfo is Unavailable) {
      //Signed in, but some kind of error when connecting to destiny.gg
      return Column(
        children: [
          OutlineButton(
            borderSide: BorderSide(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text("Sign in"),
            onPressed: () => model.navigateToAuth(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Authentication failed.\nDestiny.gg could be down.\nOr you need to try signing in again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    } else if (sessionInfo is Available) {
      //User is signed in
      return Text(
        "Signed in as: ${sessionInfo.nick}",
        textAlign: TextAlign.center,
      );
    } else {
      return Text("Error");
    }
  }

  Widget _buildLargeButton(
    String text,
    IconData icon,
    Function function,
    Color backgroundColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: RaisedButton(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Container(height: 4),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        onPressed: function,
      ),
    );
  }
}
