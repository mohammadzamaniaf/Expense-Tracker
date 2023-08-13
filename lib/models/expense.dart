import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String price;

  @HiveField(2)
  final bool isIncome;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String imageUrl;

  @HiveField(5)
  final String description;

  Expense({
    required this.name,
    required this.description,
    required this.price,
    required this.isIncome,
    required this.date,
    required this.imageUrl,
  });
}
