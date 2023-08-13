import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hive/hive.dart';

class CalendersScreen extends StatefulWidget {
  const CalendersScreen({Key? key}) : super(key: key);

  static const routeName = '/calender';

  @override
  State<CalendersScreen> createState() => _CalendersScreenState();
}

class _CalendersScreenState extends State<CalendersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocaleText('calenderType'),
      ),
      body: Column(children: [
        ListTile(
            title: const LocaleText('solar'),
            onTap: () {
              Hive.box<String>('calender').put('calenderType', 'solar');
              Navigator.of(context).pop();
            }
        ),
        ListTile(
            title: const LocaleText('gregorian'),
            onTap: () {
              Hive.box<String>('calender').put('calenderType', 'gregorian');
              Navigator.of(context).pop();
            }),
      ]),
    );
  }
}
