import 'package:dgg/datamodels/session_info.dart';
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
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Center(
          child: Column(
            children: [
              _buildSessionWidget(model),
              RaisedButton(
                child: Text("Go to chat"),
                onPressed: () => model.navigateToChat(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionWidget(HomeViewModel model) {
    SessionInfo sessionInfo = model.sessionInfo;
    if (sessionInfo == null) {
      //Loading
      return CircularProgressIndicator();
    } else if (sessionInfo is Unavailable) {
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
