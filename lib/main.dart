import 'dart:async';

import 'package:convention_ninja/pages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<User?> _sub;
  final _navigatorKey = GlobalKey<NavigatorState>();
  late String _organization;

  @override
  void initState() {
    super.initState();
    print('myapp@initstate');
    _sub = FirebaseAuth.instance.userChanges().listen((event) {
      // _navigatorKey.currentState!.pushReplacementNamed(
      //   event != null ? '/dashboard' : '/login',
      // );
    });
    _organization = '';
  }

  void setOrganization(String organization) {
    print(organization);
    setState(() {
      _organization = organization;
      print(_organization);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Convention.Ninja',
      navigatorKey: _navigatorKey,
      darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepOrange, brightness: Brightness.dark),
          useMaterial3: true),
      themeMode: ThemeMode.dark,
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/login' : '/dashboard',
      onGenerateRoute: (settings) {
        print(settings.name);
        switch (settings.name) {
          case '/':
          case '/login':
            print('gets here');
            return MaterialPageRoute(
              builder: (context) {
                print("gets here .5");
                return AdminScaffold(
                    organizationUpdater: setOrganization,
                    organization: _organization,
                    buildContext: context,
                    child: const Text('test child'));
              },
              settings: const RouteSettings(name: '/login')
            );
          case '/orgs/new':
            print('gets here 2');
            return MaterialPageRoute(builder: (context) {
              print("gets here 2.5");
              return MyHomePage(title: settings.name ?? '');
            }, settings: const RouteSettings(name: '/orgs/new'));
          default:
            return MaterialPageRoute(builder: (context) {
              return MyHomePage(title: settings.name ?? '');
            });
        }
      },
    );
  }
}

const Widget _verticalSpacer = SizedBox(height: 8.0);

class AdminScaffold extends StatelessWidget {
  late final void Function(String organization) _organizationUpdater;
  late final String _organization;
  late final Widget _child;
  late final BuildContext _buildContext;

  AdminScaffold(
      {Key? key,
      required void Function(String organization) organizationUpdater,
      required String organization,
      required Widget child,
      required BuildContext buildContext})
      : super(key: key) {
    _organizationUpdater = organizationUpdater;
    _organization = organization;
    _child = child;
    _buildContext = buildContext;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 10,
          title: Text(_organization),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
                icon: const FaIcon(FontAwesomeIcons.sitemap),
                onSelected: (String item) {
                  print(item);
                  _organizationUpdater(item);
                },
                itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Test Org',
                        child: Text('Test'),
                      ),
                      PopupMenuItem<String>(
                          value: '',
                          child: const Text('New Organization'),
                          onTap: () {
                            Navigator.pushNamed(_buildContext, '/orgs/new');
                          }),
                    ]),
            IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                })
          ],
        ),
        body: Row(children: [
          Semantics(
              explicitChildNodes: true,
              child: Material(
                  elevation: 0.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      _verticalSpacer,
                      Expanded(
                        child: Align(
                            alignment: const Alignment(0, -1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 150, maxWidth: 250),
                                  child: ExpansionPanelList(
                                    expandedHeaderPadding: EdgeInsets.zero,
                                    elevation: 0,
                                    children: [
                                      ExpansionPanel(
                                          headerBuilder: (BuildContext context,
                                              bool isExpanded) {
                                            return const ListTile(
                                              leading: FaIcon(
                                                FontAwesomeIcons.warehouse,
                                                size: 15,
                                                semanticLabel:
                                                    'Asset Management',
                                              ),
                                              minLeadingWidth: 0.0,
                                              title: Text(
                                                'Asset Mgmt',
                                                semanticsLabel:
                                                    'Asset Management',
                                              ),
                                            );
                                          },
                                          body: Column(
                                            children: [
                                              ListTile(
                                                  leading: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .folder,
                                                          size: 15)),
                                                  minLeadingWidth: 5.0,
                                                  title:
                                                      const Text('Categories'),
                                                  onTap: () {}),
                                              ListTile(
                                                  leading: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .industry,
                                                          size: 15)),
                                                  minLeadingWidth: 5.0,
                                                  title: const Text(
                                                      'Manufacturers'),
                                                  onTap: () {}),
                                              ListTile(
                                                  leading: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .boxesStacked,
                                                          size: 15)),
                                                  minLeadingWidth: 5.0,
                                                  title: const Text('Models'),
                                                  onTap: () {}),
                                              ListTile(
                                                  leading: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .barcode,
                                                          size: 15)),
                                                  minLeadingWidth: 5.0,
                                                  title: const Text('Assets'),
                                                  onTap: () {}),
                                              ListTile(
                                                  leading: const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0),
                                                      child: FaIcon(
                                                          FontAwesomeIcons
                                                              .truckFast,
                                                          size: 15)),
                                                  minLeadingWidth: 5.0,
                                                  title:
                                                      const Text('Manifests'),
                                                  onTap: () {}),
                                            ],
                                          ),
                                          isExpanded: true)
                                    ],
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Center(child: _child),
              ],
            ),
          )
        ]));
  }
}

class StatefulWrapper extends StatefulWidget {
  final Function onInit;
  final Widget child;

  const StatefulWrapper({required this.onInit, required this.child});

  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<StatefulWrapper> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class PageWrapper extends StatelessWidget {
  const PageWrapper(
      {Key? key,
      required this.title,
      required this.navigation,
      required this.child})
      : super(key: key);

  final String title;
  final Map<String, Widget?> navigation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Row(children: <Widget>[
          NavigationRail(
            selectedIndex: 0,
            extended: true,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text('Home')),
              NavigationRailDestination(
                  icon: Icon(Icons.close), label: Text('Other'))
            ],
          ),
          Column(children: const [
            Padding(
                padding: EdgeInsets.all(15.0),
                child: Expanded(child: Text('test 2')))
          ])
        ]));
  }
}

class MyHomePage extends StatefulWidget {
  var title;

  MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState(title);
}

class _MyHomePageState extends State<MyHomePage> {
  final String title;

  _MyHomePageState(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
          child: Text(title),
          onTap: () {
            FirebaseAuth.instance.signOut();
          }),
    );
  }
}
