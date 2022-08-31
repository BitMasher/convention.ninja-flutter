import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_repository/inventory_repository.dart';
import 'package:organization_repository/organization_repository.dart';

import 'app/view/app.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var fbApp = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AuthenticationRepository authenticationRepository = AuthenticationRepository(
      firebaseAuth: FirebaseAuth.instanceFor(app: fbApp));
  OrganizationRepository organizationRepository =
      OrganizationRepository(authRepo: authenticationRepository);
  CategoryRepository categoryRepository =
      CategoryRepository(authRepo: authenticationRepository);
  ManufacturerRepository manufacturerRepository =
      ManufacturerRepository(authRepo: authenticationRepository);
  ModelRepository modelRepository =
      ModelRepository(authRepo: authenticationRepository);
  AssetRepository assetRepository =
      AssetRepository(authRepo: authenticationRepository);
  ManifestRepository manifestRepository =
      ManifestRepository(authRepo: authenticationRepository);
  runApp(App(
    authenticationRepository: authenticationRepository,
    organizationRepository: organizationRepository,
    categoryRepository: categoryRepository,
    manufacturerRepository: manufacturerRepository,
    modelRepository: modelRepository,
    assetRepository: assetRepository,
    manifestRepository: manifestRepository,
  ));
}
