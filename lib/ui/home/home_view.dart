import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text("Go to auth"),
                onPressed: () => model.navigateToAuth(),
              ),
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
}
