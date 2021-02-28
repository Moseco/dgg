// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../ui/views/screens.dart';

class Routes {
  static const String chatView = '/';
  static const String authView = '/auth-view';
  static const String settingsView = '/settings-view';
  static const String onboardingView = '/onboarding-view';
  static const all = <String>{
    chatView,
    authView,
    settingsView,
    onboardingView,
  };
}

class AutoRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.chatView, page: ChatView),
    RouteDef(Routes.authView, page: AuthView),
    RouteDef(Routes.settingsView, page: SettingsView),
    RouteDef(Routes.onboardingView, page: OnboardingView),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    ChatView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const ChatView(),
        settings: data,
      );
    },
    AuthView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const AuthView(),
        settings: data,
      );
    },
    SettingsView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const SettingsView(),
        settings: data,
      );
    },
    OnboardingView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const OnboardingView(),
        settings: data,
      );
    },
  };
}
