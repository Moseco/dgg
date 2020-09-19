import 'package:auto_route/auto_route_annotations.dart';
import 'package:dgg/ui/screens.dart';

@MaterialAutoRouter(routes: [
  MaterialRoute(page: HomeView, initial: true),
  MaterialRoute(page: AuthView),
  MaterialRoute(page: ChatView),
])
class $Router {}
