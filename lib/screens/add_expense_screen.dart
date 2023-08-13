import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:hive/hive.dart';

import '/models/expense.dart';

class AddExpenseScreen extends StatefulWidget {
  final int index;

  static const routeName = '/add_expense';

  const AddExpenseScreen({Key? key, required this.index}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool isIncome = false;
  String imageUrl = 'other';
  bool? isUpdating;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  late Box expenseBox;
  late Box pocketBox;

  List<String> expenseIconNames = [
    'accessory',
    'award',
    'clothes',
    'cosmetic',
    'drink',
    'electric',
    'entertainment',
    'fitness',
    'food',
    'fruit',
    'gift',
    'grocery',
    'medical',
    'shopping',
    'water',
    'bill',
    'sport',
    'transportation',
    'other'
  ];

  List<String> incomeIconNames = [
    'gift',
    'paycheck',
    'salary',
    'award',
    'grants',
    'sale',
    'rental',
    'refunds',
    'coupon',
    'dividends',
    'investment',
    "fees",
    'other',
  ];

  @override
  void initState() {
    expenseBox = Hive.box<Expense>('expenses');
    pocketBox = Hive.box<int>('pocket');
    isUpdating = widget.index != -1;
    if (isUpdating!) {
      titleController.text = expenseBox.getAt(widget.index).name;
      priceController.text = expenseBox.getAt(widget.index).price;
      descriptionController.text =
          expenseBox.getAt(widget.index).description ?? '';
      isIncome = expenseBox.getAt(widget.index).isIncome;
      imageUrl = expenseBox.getAt(widget.index).imageUrl;
    } else {
      Future.delayed(Duration.zero).then((_) {
        showModalBottomSheet(
          transitionAnimationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 500)),
            context: context,
            builder: (_) {
              return buildTabBar();
            });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (_) => buildTabBar(),
                            transitionAnimationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
                        );
                      },
                      controller: titleController,
                      decoration: InputDecoration(
                        suffixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                          child: Image.asset('assets/icons/$imageUrl.png', width: 40,),
                        ),
                        enabledBorder: const OutlineInputBorder(),
                        hintText:
                            Locales.string(context, 'expenseOrIncomeType'),
                        labelText:
                            Locales.string(context, 'expenseOrIncomeType'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (input) => input!.trim().isEmpty
                          ? Locales.string(context, 'nameError')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(),
                        hintText: Locales.string(context, 'price'),
                        labelText: Locales.string(context, 'price'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (input) => input!.trim().isEmpty
                          ? Locales.string(context, 'priceError')
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(),
                        hintText: Locales.string(context, 'description'),
                        labelText: Locales.string(context, 'description'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // TAB BAR ------ TAB BAR ------ TAB BAR ------ TAB BAR
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 40,
        width: double.infinity,
        color: Colors.blue,
        child: ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              // Add Expense to Total Expense
              int currentTotalExpense = await pocketBox.get('totalExpense');

              // Add Income to Total Income
              int currentTotalIncome = await pocketBox.get('totalIncome');

              // Add Income / Expense to Budget
              int currentBudget = await pocketBox.get('budget');

              // The money from price controller text field
              int newMoney = int.parse(priceController.text);

              Expense expense = Expense(
                name: titleController.text,
                price: priceController.text,
                description: descriptionController.text,
                isIncome: isIncome,
                date: currentDate,
                imageUrl: imageUrl,
              );

              if (isUpdating!) {
                // get specific item's value to update
                int itemValue =
                    int.parse(await expenseBox.getAt(widget.index).price);
                bool wasExpense =
                    expenseBox.getAt(widget.index).isIncome == false;

                if (isIncome) {
                  if (wasExpense) {
                    // if it was previously an expense

                    // update total income and total expense if it was previously an expense
                    currentTotalExpense -= itemValue;
                    currentTotalIncome += newMoney;

                    // update the budget if it was previously an expense
                    int newBudget = newMoney + itemValue;

                    pocketBox.put('budget', newBudget + currentBudget);
                    pocketBox.put('totalIncome', currentTotalIncome);
                    pocketBox.put('totalExpense', currentTotalExpense);
                  } else {
                    // if it was an income already

                    // update total expense and total income if it was an income already
                    currentTotalIncome -= itemValue;
                    currentTotalIncome += newMoney;

                    // update the budget if it was an income already
                    currentBudget -= itemValue;
                    currentBudget += newMoney;

                    pocketBox.put('budget', currentBudget);
                    pocketBox.put('totalIncome', currentTotalIncome);
                  }
                } else {
                  // IF IS EXPENSE
                  if (wasExpense == false) {
                    // If it was income before

                    // update total income and total expense if it was income before
                    currentTotalIncome -= itemValue;
                    currentTotalExpense += newMoney;

                    // update budget if it was income before
                    int result = newMoney + itemValue;
                    int newBudget = currentBudget - result;

                    pocketBox.put('totalIncome', currentTotalIncome);
                    pocketBox.put('totalExpense', currentTotalExpense);
                    pocketBox.put('budget', newBudget);
                  } else {
                    // update total expense if it was an expense already
                    currentTotalExpense -= itemValue;
                    currentTotalExpense += newMoney;

                    // update the budget if it was an expense already
                    currentBudget += itemValue;
                    int newBudget = currentBudget - newMoney;

                    pocketBox.put('totalExpense', currentTotalExpense);
                    pocketBox.put('budget', newBudget);
                  }
                }
                await expenseBox.putAt(widget.index, expense);
              } else {
                // WE ARE ADDING NEW EXPENSE / INCOME
                if (isIncome) {
                  // Add income to total income
                  int newTotalIncome = currentTotalIncome + newMoney;
                  await pocketBox.put('totalIncome', newTotalIncome);

                  // Add income to budget
                  int newBudget = newMoney + currentBudget;
                  await pocketBox.put('budget', newBudget);
                } else {
                  // Add expense to total expense
                  int newTotalExpense = currentTotalExpense + newMoney;
                  await pocketBox.put('totalExpense', newTotalExpense);

                  // Add expense to budget
                  int newBudget = currentBudget - newMoney;
                  await pocketBox.put('budget', newBudget);
                }
                // Add the new expense to expense box
                expenseBox.add(expense);
              }
              Navigator.pop(context);
            }
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(10),
          ),
          child: const LocaleText('addAmount'),
        ),
      ),
    );
  }

  Widget buildTabBar() {
    List<String> localeExpenseIconNames = [
      Locales.string(context, 'accessory_label'),
      Locales.string(context, 'award_label'),
      Locales.string(context, 'clothes_label'),
      Locales.string(context, 'cosmetic_label'),
      Locales.string(context, 'drink_label'),
      Locales.string(context, 'electric_label'),
      Locales.string(context, 'entertainment_label'),
      Locales.string(context, 'fitness_label'),
      Locales.string(context, 'food_label'),
      Locales.string(context, 'fruit_label'),
      Locales.string(context, 'gift_label'),
      Locales.string(context, 'grocery_label'),
      Locales.string(context, 'medical_label'),
      Locales.string(context, 'shopping_label'),
      Locales.string(context, 'water_label'),
      Locales.string(context, 'bill_label'),
      Locales.string(context, 'sport_label'),
      Locales.string(context, 'transportation_label'),
      Locales.string(context, 'others_label'),
    ];

    List<String> localeIncomeIconNames = [
      Locales.string(context, 'gift_label'),
      Locales.string(context, 'paycheck_label'),
      Locales.string(context, 'salary_label'),
      Locales.string(context, 'award_label'),
      Locales.string(context, 'grants_label'),
      Locales.string(context, 'sale_label'),
      Locales.string(context, 'rental_label'),
      Locales.string(context, 'refunds_label'),
      Locales.string(context, 'coupons_label'),
      Locales.string(context, 'dividends_label'),
      Locales.string(context, 'investment_label'),
      Locales.string(context, 'fees'),
      Locales.string(context, 'others_label'),
    ];

    return SizedBox(
      width: double.infinity,
      height: 400,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 35,
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  overlayColor: MaterialStateProperty.all(Colors.black54),
                  onTap: (tapIndex) {
                    if (tapIndex == 0) {
                      isIncome = false;
                    } else if (tapIndex == 1) {
                      isIncome = true;
                    }
                  },
                  tabs: const [
                    Tab(
                      height: 30,
                      child: LocaleText('expense'),
                    ),
                    Tab(
                      height: 30,
                      child: LocaleText('income'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: expenseIconNames.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        titleController.text =
                            localeExpenseIconNames[index].toString();
                        imageUrl = expenseIconNames[index];
                        Navigator.of(context).pop();
                      });
                    },
                    child: IconGrid(
                      iconName: expenseIconNames[index],
                      iconLabel: localeExpenseIconNames[index],
                    ),
                  );
                },
              ),

              // Income list
              GridView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: incomeIconNames.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        titleController.text = localeIncomeIconNames[index];
                        imageUrl = incomeIconNames[index];
                        Navigator.of(context).pop();
                      });
                    },
                    child: IconGrid(
                      iconName: incomeIconNames[index],
                      iconLabel: localeIncomeIconNames[index],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IconGrid extends StatelessWidget {
  const IconGrid({Key? key, required this.iconName, required this.iconLabel})
      : super(key: key);
  final String iconName;
  final String iconLabel;

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Column(
        children: [
          Image.asset(
            'assets/icons/$iconName.png',
            width: 40,
          ),
          const SizedBox(height: 5),
          Expanded(child: Text(iconLabel, textAlign: TextAlign.center))
        ],
      ),
    );
  }
}
