import 'package:expense_tracker/screens/calenders_screen.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '/models/expense.dart';
import '/screens/home_screen.dart';
import '/screens/debt_screen.dart';
import '/screens/language_screen.dart';
import '/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(path.path);
  Hive.registerAdapter(ExpenseAdapter());
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<int>('pocket');
  await Hive.openBox<String>('calender');
  await Locales.init(['en', 'fa', 'zh', 'ar', 'es', 'hi']);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(
      builder: (locale) => MaterialApp(
        localizationsDelegates: Locales.delegates,
        supportedLocales: Locales.supportedLocales,
        locale: locale,
        routes: {
          DebtScreen.routeName: (context) => const DebtScreen(),
          SettingsScreen.routeName: (context) => const SettingsScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          LanguageScreen.routeName: (context) => const LanguageScreen(),
          CalendersScreen.routeName: (context) => const CalendersScreen(),
        },
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scrollbarTheme:  ScrollbarThemeData(
            interactive: true,
            radius: const Radius.circular(10.0),
            thumbColor: MaterialStateProperty.all(Colors.deepOrange.withOpacity(0.6)),
            thickness: MaterialStateProperty.all(20.0),
            minThumbLength: 100,
          ),
          primaryColor: Colors.deepOrange,
          colorScheme: const ColorScheme.dark(
            surface: Colors.deepOrange,
            // color of app bar
            onSurface: Colors.white,
            // everything on appbar
            secondary: Colors.deepPurple,
            // floating action button
            onSecondary: Colors.white,
            // everything on FAB
            primary: Colors.deepOrange, // background of the buttons
          ).copyWith(secondary: Colors.deepPurple),
        ),
        home: FutureBuilder(
          future: Hive.openBox<Expense>('expenses'),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Scaffold(
                  backgroundColor: Colors.lightBlueAccent,
                  body: Center(
                    child: Text(
                      'An Error Has Occurred',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                );
              } else {
                // Hive.box<Expense>('expenses').clear();
                // Hive.box<int>('pocket').clear();
                if (Hive.box<int>('pocket').isEmpty) {
                  Hive.box<int>('pocket').put('totalIncome', 0);
                  Hive.box<int>('pocket').put('totalExpense', 0);
                  Hive.box<int>('pocket').put('salary', 0);
                  Hive.box<int>('pocket').put('budget', 0);
                }
                if(Hive.box<String>('calender').isEmpty) {
                  Hive.box<String>('calender').put('calenderType', 'solar');
                }
                return const BottomNavigationBarScreen();
              }
            } else {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Loading',
                        style: TextStyle(fontSize: 25),
                      )
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class BottomNavigationBarScreen extends StatefulWidget {
  const BottomNavigationBarScreen({Key? key}) : super(key: key);

  @override
  State<BottomNavigationBarScreen> createState() =>
      _BottomNavigationBarScreenState();
}

class _BottomNavigationBarScreenState extends State<BottomNavigationBarScreen> {
  List<Widget> pages = [
    const HomeScreen(),
    const DebtScreen(),
    const SettingsScreen()
  ];
  List<BottomNavigationBarItem> items = [];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: true,
        showUnselectedLabels: false,
        currentIndex: index,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home, size: 25), label: Locales.string(context, 'home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.money, size: 25), label: Locales.string(context, 'debt')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.settings, size: 25), label: Locales.string(context, 'settings'))
        ],
        onTap: (index) {
          setState(() => this.index = index);
        },
      ),
    );
  }
}
