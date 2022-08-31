import 'package:authentication_repository/authentication_repository.dart';
import 'package:convention_ninja/app/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_repository/inventory_repository.dart';
import 'package:organization_repository/organization_repository.dart';

import '../bloc/app_bloc.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required AuthenticationRepository authenticationRepository,
    required OrganizationRepository organizationRepository,
    required CategoryRepository categoryRepository,
    required ManufacturerRepository manufacturerRepository,
    required ModelRepository modelRepository,
    required AssetRepository assetRepository,
    required ManifestRepository manifestRepository,
  })  : _authenticationRepository = authenticationRepository,
        _organizationRepository = organizationRepository,
        _categoryRepository = categoryRepository,
        _manufacturerRepository = manufacturerRepository,
        _modelRepository = modelRepository,
        _assetRepository = assetRepository,
        _manifestRepository = manifestRepository;

  final AuthenticationRepository _authenticationRepository;
  final OrganizationRepository _organizationRepository;
  final CategoryRepository _categoryRepository;
  final ManufacturerRepository _manufacturerRepository;
  final ModelRepository _modelRepository;
  final AssetRepository _assetRepository;
  final ManifestRepository _manifestRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: _authenticationRepository),
          RepositoryProvider.value(value: _organizationRepository),
          RepositoryProvider.value(value: _categoryRepository),
          RepositoryProvider.value(value: _manufacturerRepository),
          RepositoryProvider.value(value: _modelRepository),
          RepositoryProvider.value(value: _assetRepository),
          RepositoryProvider.value(value: _manifestRepository),
        ],
        child: BlocProvider(
            create: (_) =>
                AppBloc(authenticationRepository: _authenticationRepository),
            child: const AppView()));
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      debugShowCheckedModeBanner: false,
    );
  }
}
