
import 'package:beamer/beamer.dart';
import 'package:convention_ninja/pages/dashboard_creation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../pages/dashboard_landing_page.dart';

class DashboardLocation extends BeamLocation<BeamState> {
  DashboardLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => [
    '/dashboard',
    '/dashboard/new',
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
    if(state.uri.path == "/dashboard")
      const BeamPage(child: DashboardLandingPage()),
    if(state.uri.path == "/dashboard/new")
      const BeamPage(child: DashboardCreationPage())
  ];

}