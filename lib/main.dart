import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_service_manager/l10n/app_localizations.dart';
import 'package:mobile_service_manager/presentation/providers/locale_provider.dart';
import 'package:mobile_service_manager/presentation/providers/object_box_provider.dart';
import 'package:mobile_service_manager/presentation/screens/brand_list_screen.dart';
import 'package:mobile_service_manager/presentation/screens/fault_list_screen.dart';
import 'package:mobile_service_manager/presentation/screens/revenue_screen.dart';
import 'package:mobile_service_manager/presentation/screens/service_item_list_screen.dart';
import 'package:mobile_service_manager/presentation/screens/setting_screen.dart';
import 'package:mobile_service_manager/presentation/screens/technician_list_screen.dart';
import 'package:mobile_service_manager/presentation/screens/trash_list_screen.dart';
import 'package:window_size/window_size.dart';
import 'core/constants/app_colors.dart';
import 'data/database/object_box.dart';
import 'firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(800, 600));
    setWindowTitle('Mobile Service Manager');
  }

  final objectBox = await ObjectBox.create();

  try {
    await _initializeFirebase();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        objectBoxProvider.overrideWithValue(objectBox),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void _onTabSelectedToLog(int index) {
  FirebaseAnalytics.instance.logEvent(
    name: _screenNameList[index],
    parameters: {'tab_index': index, 'tab_name': _screenNameList[index]},
  );
}

List<String> _screenNameList = [
  'Service',
  'Brand',
  'Technician',
  'Error',
  'Bin',
  'Revenue',
  'Setting'
];

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Mobile Service Manager',
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          colorSchemeSeed: Colors.white,
          textTheme:
              GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(color: Colors.black),
            hintStyle: TextStyle(color: AppColors.hintColor),
          )),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ServiceItemListScreen(),
    BrandListScreen(),
    TechnicianListScreen(),
    FaultListScreen(),
    TrashListScreen(),
    RevenueScreen(),
    SettingScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _onTabSelectedToLog(index);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final navLabels = [
      t?.list ?? 'List',
      t?.brand ?? 'Brand',
      t?.technician ?? 'Technician',
      t?.error ?? 'Error',
      t?.bin ?? 'Bin',
      t?.revenue ?? 'Revenue',
      t?.setting ?? 'Setting',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            backgroundColor: AppColors.navigationBackground,
            selectedLabelTextStyle: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelTextStyle: GoogleFonts.montserrat(
              color: AppColors.navigationUnselectedText,
            ),
            destinations: [
              _navigationItem(
                  icon: CupertinoIcons.square_list, text: navLabels[0]),
              _navigationItem(
                  icon: Icons.phone_android_rounded, text: navLabels[1]),
              _navigationItem(icon: Icons.engineering, text: navLabels[2]),
              _navigationItem(
                  icon: Icons.error_outline_rounded, text: navLabels[3]),
              _navigationItem(
                  icon: CupertinoIcons.archivebox, text: navLabels[4]),
              _navigationItem(
                  icon: CupertinoIcons.money_dollar_circle, text: navLabels[5]),
              _navigationItem(
                  icon: CupertinoIcons.settings, text: navLabels[6]),
            ],
          ),

          // Main Content Area
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _navigationItem(
      {required IconData icon, required String text}) {
    return NavigationRailDestination(
      icon: Icon(icon, color: AppColors.navigationUnselectedIcon),
      selectedIcon: Icon(icon, color: AppColors.navigationSelectedIcon),
      label: Text(text),
    );
  }
}
