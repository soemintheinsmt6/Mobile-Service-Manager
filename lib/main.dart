import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/providers/object_box_provider.dart';
import 'package:mobile_service_manager/screens/brand_list_screen.dart';
import 'package:mobile_service_manager/screens/fault_list_screen.dart';
import 'package:mobile_service_manager/screens/revenue_screen.dart';
import 'package:mobile_service_manager/screens/service_item_list_screen.dart';
import 'package:mobile_service_manager/screens/setting_screen.dart';
import 'package:mobile_service_manager/screens/technician_list_screen.dart';
import 'package:mobile_service_manager/screens/trash_list_screen.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_size/window_size.dart';
import 'constants/app_colors.dart';
import 'database/object_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(800, 600));
    setWindowTitle('Mobile Service Manager');
  }
  await tempDeleteObjectBoxDatabase();

  final objectBox = await ObjectBox.create();
  runApp(
    ProviderScope(
      overrides: [
        objectBoxProvider.overrideWithValue(objectBox),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> tempDeleteObjectBoxDatabase() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final isDeleted = prefs.getBool('isServiceItemsDeleted');

  if (isDeleted == null || isDeleted == false) {
    final docsDir = await getApplicationDocumentsDirectory();
    final objectBoxDir = Directory(p.join(docsDir.path, "objectbox-db"));

    if (await objectBoxDir.exists()) {
      await objectBoxDir.delete(recursive: true);
    }
    prefs.setBool('isServiceItemsDeleted', true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Service Manager',
      debugShowCheckedModeBanner: false,
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          SizedBox(
            width: kNavigationBarWidth,
            child: NavigationRail(
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
                    icon: CupertinoIcons.square_list, text: 'Service'),
                _navigationItem(
                    icon: Icons.phone_android_rounded, text: 'Brand'),
                _navigationItem(icon: Icons.engineering, text: 'Technician'),
                _navigationItem(
                    icon: Icons.error_outline_rounded, text: 'Error'),
                _navigationItem(icon: CupertinoIcons.archivebox, text: 'Bin'),
                _navigationItem(
                    icon: CupertinoIcons.money_dollar_circle, text: 'Revenue'),
                _navigationItem(icon: CupertinoIcons.settings, text: 'Setting'),
              ],
            ),
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
