// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../ui/views/screens.dart';

class Routes {
  static const String homeView = '/';
  static const String authView = '/auth-view';
  static const String chatView = '/chat-view';
  static const all = <String>{
    homeView,
    authView,
    chatView,
  };
}

class AutoRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.authView, page: AuthView),
    RouteDef(Routes.chatView, page: ChatView),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    HomeView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const HomeView(),
        settings: data,
      );
    },
    AuthView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const AuthView(),
        settings: data,
      );
    },
    ChatView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const ChatView(),
        settings: data,
      );
    },
  };
}
