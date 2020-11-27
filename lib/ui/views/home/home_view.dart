import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/ui/widgets/delayed_widget.dart';
import 'package:flutter/material.dart';
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Image.asset(
                      "assets/dgg_icon.png",
                      width: 150,
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
    return Column(
      children: [
        _buildSessionWidget(model),
        RaisedButton(
          child: Text("Go to chat"),
          onPressed: () => model.navigateToChat(),
        ),
      ],
    );
  }

  Widget _buildSessionWidget(HomeViewModel model) {
    SessionInfo sessionInfo = model.sessionInfo;

    if (sessionInfo is Unavailable) {
      //Not signed or some kind of error
      return RaisedButton(
        child: Text("Sign in"),
        onPressed: () => model.navigateToAuth(),
      );
    } else if (sessionInfo is Available) {
      //User is signed in
      return Text("Signed in as: ${sessionInfo.nick}");
    } else {
      return Text("Error");
    }
  }
}
