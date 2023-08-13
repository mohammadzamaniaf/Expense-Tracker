import 'package:flutter_locales/flutter_locales.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:shamsi_date/shamsi_date.dart';

import '/screens/add_expense_screen.dart';
import '/screens/home_screen.dart';
import '/models/expense.dart';

class ExpenseListTile extends StatefulWidget {
  const ExpenseListTile({Key? key, required this.expense, required this.index})
      : super(key: key);

  final Expense expense;
  final int index;

  @override
  State<ExpenseListTile> createState() => _ExpenseListTileState();
}

class _ExpenseListTileState extends State<ExpenseListTile> {
  late Box expenseBox;
  late Box pocketBox;
  String? calenderType;
  String? dateTime;

  @override
  void initState() {
    expenseBox = Hive.box<Expense>('expenses');
    pocketBox = Hive.box<int>('pocket');
    calenderType = Hive.box<String>('calender').get('calenderType');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Jalali j = DateTime.now().toJalali();
    Gregorian g = DateTime.now().toGregorian();

    if (calenderType == 'gregorian') {
      g = widget.expense.date.toGregorian();
    } else if (calenderType == 'solar') {
      j = widget.expense.date.toJalali();
    }

    String format(Date d) {
      final f = d.formatter;

      return '${f.yyyy}/${f.mm}/${f.dd}  ${f.wN}';
    }

    return Container(
      margin: const EdgeInsets.only(right: 15, left: 10, top: 5, bottom: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        border: Border.all(),
      ),
      child: Slidable(
        actionPane: const SlidableStrechActionPane(),

        // left side
        actions: [
          IconSlideAction(
            caption: Locales.string(context, 'edit'),
            color: Colors.green[700],
            icon: Icons.edit,
            onTap: () => onDismissed(widget.index, SlidableAction.edit),
          ),
        ],

        // right side
        secondaryActions: [
          IconSlideAction(
            caption: Locales.string(context, 'delete'),
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => onDismissed(widget.index, SlidableAction.delete),
          )
        ],
        child: ListTile(
          dense: true,
          leading: Image.asset('assets/icons/${widget.expense.imageUrl}.png'),
          // ),
          title: Text(
            widget.expense.name,
            style: const TextStyle(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Visibility(
                visible: widget.expense.description.isNotEmpty ? true : false,
                child: Text(widget.expense.description),
              ),
              Text(calenderType == 'solar' ? format(j) : format(g))
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.expense.isIncome
                    ? widget.expense.price
                    : '–${widget.expense.price}',
                style: TextStyle(
                    fontSize: 20,
                    color: widget.expense.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onDismissed(int index, SlidableAction action) async {
    switch (action) {
      case SlidableAction.edit:
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddExpenseScreen(index: widget.index)));
        break;

      case SlidableAction.delete:
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                title: const LocaleText('deleteItem'),
                content: const LocaleText('deleteMessage'),
                contentPadding: const EdgeInsets.only(
                    bottom: 5, top: 15, left: 20, right: 20),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      int currentTotalExpense =
                          await pocketBox.get('totalExpense');
                      int currentTotalIncome =
                          await pocketBox.get('totalIncome');
                      int currentBudget = await pocketBox.get('budget');
                      final oldMoney =
                          int.parse(await expenseBox.getAt(index).price);
                      final isIncome = await expenseBox.getAt(index).isIncome;

                      if (isIncome) {
                        currentTotalIncome -= oldMoney;
                        currentBudget -= oldMoney;
                      } else {
                        currentTotalExpense -= oldMoney;
                        currentBudget += oldMoney;
                      }
                      pocketBox.put('totalExpense', currentTotalExpense);
                      pocketBox.put('totalIncome', currentTotalIncome);
                      pocketBox.put('budget', currentBudget);
                      expenseBox.deleteAt(index);

                      Navigator.of(context).pop();
                    },
                    child: const LocaleText('yes'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const LocaleText('no'),
                  ),
                ],
              );
            });
        break;
    }
  }
}
