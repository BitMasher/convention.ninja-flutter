import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../dashboard/organization/inventory/assets/view/inventory_asset_page.dart';
import '../../dashboard/organization/inventory/assets/view/inventory_assets_page.dart';
import '../../dashboard/organization/inventory/categories/view/inventory_categories_page.dart';
import '../../dashboard/organization/inventory/import/view/inventory_import_page.dart';
import '../../dashboard/organization/inventory/manifests/view/inventory_manifest_page.dart';
import '../../dashboard/organization/inventory/manifests/view/inventory_manifests_page.dart';
import '../../dashboard/organization/inventory/manufacturers/view/inventory_manufacturers_page.dart';
import '../../dashboard/organization/inventory/models/view/inventory_models_page.dart';
import '../../dashboard/organization/inventory/view/inventory_dashboard_page.dart';
import '../../dashboard/organization/view/new_org_page.dart';
import '../../dashboard/organization/view/org_dashboard_page.dart';
import '../../dashboard/view/dashboard_page.dart';
import '../../login/view/login_page.dart';
import '../../onboard/view/onboard_page.dart';
import '../bloc/app_bloc.dart';

final GoRouter router = GoRouter(
    routes: <GoRoute>[
      GoRoute(path: '/', redirect: (_) => '/dashboard', routes: <GoRoute>[
        GoRoute(
            path: 'dashboard',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                const NoTransitionPage(child: DashboardPage()),
            routes: <GoRoute>[
              GoRoute(
                path: 'new',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const NoTransitionPage(child: NewOrgPage()),
              ),
              GoRoute(
                  path: ':orgId',
                  pageBuilder: (BuildContext context, GoRouterState state) =>
                      NoTransitionPage(
                          child: OrgDashboardPage(
                              organizationId: state.params['orgId']!)),
                  routes: <GoRoute>[
                    GoRoute(
                        path: 'inventory',
                        pageBuilder:
                            (BuildContext context, GoRouterState state) =>
                                NoTransitionPage(
                                  child: InventoryDashboardPage(
                                      organizationId: state.params['orgId']!),
                                ),
                        routes: <GoRoute>[
                          GoRoute(
                              path: 'categories',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryCategoriesPage(
                                        organizationId: state.params['orgId']!),
                                  )),
                          GoRoute(
                              path: 'manufacturers',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryManufacturersPage(
                                        organizationId: state.params['orgId']!),
                                  )),
                          GoRoute(
                              path: 'models',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryModelsPage(
                                        organizationId: state.params['orgId']!),
                                  )),
                          GoRoute(
                              path: 'assets',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryAssetsPage(
                                        organizationId: state.params['orgId']!),
                                  ),
                              routes: <GoRoute>[
                                GoRoute(
                                  path: ':assetId',
                                  pageBuilder: (BuildContext context,
                                          GoRouterState state) =>
                                      NoTransitionPage(
                                        child: InventoryAssetPage(
                                            organizationId:
                                                state.params['orgId']!,
                                            assetId: state.params['assetId']!),
                                      ),
                                )
                              ]),
                          GoRoute(
                              path: 'manifests',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryManifestsPage(
                                        organizationId: state.params['orgId']!),
                                  ),
                              routes: <GoRoute>[
                                GoRoute(
                                  path: ':manifestId',
                                  pageBuilder: (BuildContext context,
                                          GoRouterState state) =>
                                      NoTransitionPage(
                                        child: InventoryManifestPage(
                                            organizationId:
                                                state.params['orgId']!,
                                            manifestId:
                                                state.params['manifestId']!),
                                      ),
                                )
                              ]),
                          GoRoute(
                              path: 'import',
                              pageBuilder: (BuildContext context,
                                      GoRouterState state) =>
                                  NoTransitionPage(
                                    child: InventoryImportPage(
                                        organizationId: state.params['orgId']!),
                                  ))
                        ])
                  ])
            ])
      ])
    ],
    navigatorBuilder:
        (BuildContext context, GoRouterState state, Widget child) {
      return BlocBuilder<AppBloc, AppState>(
          buildWhen: (previous, state) => previous != state,
          builder: (context, state) {
            switch (state.status) {
              case AppStatus.newUser:
                return const OnboardPage();
              case AppStatus.authenticated:
                return child;
              case AppStatus.unauthenticated:
                return const LoginPage();
            }
          });
    });
