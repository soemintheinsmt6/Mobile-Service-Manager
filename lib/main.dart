import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_service_manager/providers/object_box_provider.dart';
import 'package:mobile_service_manager/screens/brand_list_screen.dart';
import 'package:window_size/window_size.dart';
import 'constants/app_colors.dart';
import 'database/object_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isMacOS) {
    setWindowMinSize(const Size(800, 600));
    setWindowTitle('Mobile Service Manager');
  }

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Service Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
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

  static const List<Widget> _screens = [BrandListScreen(), Scaffold()];

  static const List<String> _titles = [
    'Brand',
    'Technician',
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
            width: 95,
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.navigationBackground,
              selectedLabelTextStyle: GoogleFonts.montserrat(
                color: AppColors.navigationSelectedText,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelTextStyle: GoogleFonts.montserrat(
                color: AppColors.navigationUnselectedText,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.phone_android_rounded,
                      color: AppColors.navigationUnselectedIcon),
                  selectedIcon: Icon(Icons.phone_android_rounded,
                      color: AppColors.navigationSelectedIcon),
                  label: Text('Brand'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.engineering,
                      color: AppColors.navigationUnselectedIcon),
                  selectedIcon: Icon(Icons.engineering,
                      color: AppColors.navigationSelectedIcon),
                  label: Text('Technician'),
                ),
              ],
            ),
          ),
          // Vertical Divider
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.headerBackground,
                  width: double.infinity,
                  child: Text(
                    _titles[_selectedIndex],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.headerText,
                    ),
                  ),
                ),
                // Page Content
                Expanded(
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
