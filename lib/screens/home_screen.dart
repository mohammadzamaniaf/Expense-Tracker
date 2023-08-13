import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '/models/expense.dart';
import '/widgets/expense_list_tile.dart';
import '/screens/add_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static const routeName = '/home_page';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

enum SlidableAction {
  edit,
  delete,
}

class _HomeScreenState extends State<HomeScreen> {
  late Box expenseBox;
  late Box pocketBox;

  bool isFabVisible = true;

  @override
  void initState() {
    expenseBox = Hive.box<Expense>('expenses');
    pocketBox = Hive.box<int>('pocket');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<int>('pocket').listenable(),
      builder: (context, Box<int> pocketBox, child) => Scaffold(
        appBar: AppBar(
          title: const LocaleText('appName'),
          elevation: 0,
          centerTitle: true,
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.15,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const LocaleText(
                                  'appName',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  '${pocketBox.get('budget') ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const LocaleText(
                                  'income',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  '${pocketBox.get('totalIncome') ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const LocaleText(
                                  'expense',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                Text(
                                  '${pocketBox.get('totalExpense') ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: ValueListenableBuilder(
            valueListenable: Hive.box<Expense>('expenses').listenable(),
            builder: (context, Box<Expense> expensesBox, child) {
              return NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  if (notification.direction == ScrollDirection.forward) {
                    if (!isFabVisible) setState(() => isFabVisible = true);
                  } else if (notification.direction ==
                      ScrollDirection.reverse) {
                    if (isFabVisible) setState(() => isFabVisible = false);
                  }
                  return true;
                },
                child: Scrollbar(
                  thickness: 5,
                  interactive: true,
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox();
                    },
                    itemCount: expenseBox.length,
                    itemBuilder: (context, index) {
                      final expense = expenseBox.getAt(index);
                      return ExpenseListTile(index: index, expense: expense);
                    },
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: isFabVisible
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(
                      index: -1,
                    ),
                  ));
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }
}
