import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'auth_viewmodel.dart';

class AuthView extends StatelessWidget {
  const AuthView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<AuthViewModel>.reactive(
      viewModelBuilder: () => AuthViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("Auth page"),
        ),
      ),
    );
  }
}
