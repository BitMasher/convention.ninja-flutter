import 'package:beamer/beamer.dart';
import 'package:convention_ninja/components/admin_scaffold.dart';
import 'package:convention_ninja/pages/landing_page.dart';
import 'package:convention_ninja/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../pages/onboarding_page.dart';

class HomeLocation extends BeamLocation<BeamState> {
  HomeLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns =>
      ['/', '/login', '/dashboard', '/dashboard/:orgId/*', '/onboard'];

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
            pathPatterns: ['/onboard', '/login'],
            guardNonMatching: true,
            check: (context, location) =>
                ((FirebaseAuth.instance.currentUser != null &&
                    UserService.isOnboarded())),
            beamToNamed: (origin, target) => '/onboard'),
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
    if (state.uri.path == '/login') {
      return [
        const BeamPage(
            key: ValueKey('login'), title: 'Login', child: LandingPage())
      ];
    } else if(state.uri.path == '/onboard') {
      return [
        const BeamPage(
          key: ValueKey('onboard'), title: 'Onboard', child: OnboardingPage())
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
