import 'package:beamer/beamer.dart';
import 'package:convention_ninja/components/admin_scaffold.dart';
import 'package:convention_ninja/pages/landing_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class HomeLocation extends BeamLocation<BeamState> {
  HomeLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns =>
      ['/', '/login', '/dashboard', '/dashboard/:orgId/*'];

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathPatterns: ['/login'],
          guardNonMatching: true,
          check: (context, location) =>
              FirebaseAuth.instance.currentUser != null,
          beamToNamed: (origin, target) {
            return '/login';
            },
        ),
        BeamGuard(
          pathPatterns: ['/', '/login'],
          check: (context, location) =>
              FirebaseAuth.instance.currentUser == null,
          beamToNamed: (origin, target) {
            return '/dashboard';
          },
        )
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    if (state.pathPatternSegments.contains('login')) {
      return [
        const BeamPage(
            key: ValueKey('login'), title: 'Login', child: LandingPage())
      ];
    } else {
      return [
        BeamPage(
            key: ValueKey('dashboard-${state.pathParameters['orgId']}'),
            title: 'Dashboard',
            child: AdminScaffold(
                organizationId: state.pathParameters['orgId'] ?? ''))
      ];
    }
  }
}
