import 'package:flutter/material.dart';
import '../../features/mood_entry/presentation/pages/today_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/stats/presentation/pages/stats_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../spachScren.dart';

class AppRouter {
  static final router = _router();

  static RouterConfig<Object> _router() {
    return RouterConfig(
      routerDelegate: _Delegate(),
      routeInformationParser: _Parser(),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(location: '/'),
      ),
    );
  }
}

class _Parser extends RouteInformationParser<List<String>> {
  @override
  Future<List<String>> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    return uri.pathSegments.isEmpty ? [''] : uri.pathSegments;
  }

  @override
  RouteInformation? restoreRouteInformation(List<String> configuration) {
    if (configuration.isEmpty) {
      return const RouteInformation(location: '/');
    }
    return RouteInformation(location: '/${configuration.join('/')}');
  }
}

class _Delegate extends RouterDelegate<List<String>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<List<String>> {
  final GlobalKey<NavigatorState> _key = GlobalKey<NavigatorState>();
  int _index = 0;
  bool _showSplash = true;

  _Delegate() {
    // Masquer le splash après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      _showSplash = false;
      notifyListeners();
    });
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _key;

  @override
  List<String> get currentConfiguration {
    if (_showSplash) {
      return ['splash'];
    }
    switch (_index) {
      case 0:
        return ['today'];
      case 1:
        return ['history'];
      case 2:
        return ['stats'];
      case 3:
        return ['settings'];
      default:
        return ['today'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _key,
      pages: [
        if (_showSplash)
          const MaterialPage(
            key: ValueKey('splash'),
            child: SplashScreen(),
          )
        else
          MaterialPage(
            key: ValueKey('main'),
            child: Scaffold(
              body: IndexedStack(
                index: _index,
                children: const [
                  TodayPage(),
                  HistoryPage(),
                  StatsPage(),
                  SettingsPage(),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) {
                  _index = i;
                  notifyListeners();
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
                  NavigationDestination(icon: Icon(Icons.history), label: 'History'),
                  NavigationDestination(icon: Icon(Icons.analytics), label: 'Stats'),
                  NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
                ],
              ),
            ),
          ),
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }

  @override
  Future<void> setNewRoutePath(List<String> configuration) async {
    if (configuration.isEmpty || configuration.first == 'splash') {
      _showSplash = true;
    } else {
      _showSplash = false;
      switch (configuration.first) {
        case 'today':
          _index = 0;
          break;
        case 'history':
          _index = 1;
          break;
        case 'stats':
          _index = 2;
          break;
        case 'settings':
          _index = 3;
          break;
        default:
          _index = 0;
      }
    }
    notifyListeners();
  }
}