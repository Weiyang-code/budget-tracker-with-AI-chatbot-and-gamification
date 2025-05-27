import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
part 'models.g.dart';

class TimestampConverter implements JsonConverter<Timestamp, Object> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Object json) {
    return json is Timestamp
        ? json
        : Timestamp.fromMillisecondsSinceEpoch((json as int));
  }

  @override
  Object toJson(Timestamp timestamp) => timestamp;
}

@JsonSerializable()
class Wallet {
  String id;
  String name;
  String type;
  String currency;
  double balance; // or double if you prefer
  String uid;

  Wallet({
    this.id = '',
    this.name = '',
    this.balance = 0,
    this.uid = '',
    this.type = '',
    this.currency = '',
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
  Map<String, dynamic> toJson() => _$WalletToJson(this);
}

@JsonSerializable()
class Transaction {
  String uid;
  String walletId;

  @TimestampConverter()
  Timestamp date;

  double amount;
  String category;
  String note;
  String type;

  Transaction({
    this.uid = '',
    this.walletId = '',
    Timestamp? date,
    this.amount = 0,
    this.category = '',
    this.note = '',
    this.type = 'expense',
  }) : date = date ?? Timestamp.now();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class Budget {
  String id;
  String uid;
  String category;
  double amount;
  double spending; // total spending in this budget

  @TimestampConverter()
  Timestamp startTime;

  @TimestampConverter()
  Timestamp endTime;

  @TimestampConverter()
  Timestamp createdAt;

  Budget({
    this.id = '',
    this.uid = '',
    this.category = '',
    this.amount = 0.0,
    this.spending = 0.0,
    Timestamp? startTime,
    Timestamp? endTime,
    Timestamp? createdAt,
  }) : startTime = startTime ?? Timestamp.now(),
       endTime = endTime ?? Timestamp.now(),
       createdAt = createdAt ?? Timestamp.now();

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}

@JsonSerializable()
class Challenge {
  final String id;
  final String title;
  final String category;
  final double targetSpending;
  final bool completed;
  final DateTime startTime;
  final DateTime endTime;

  Challenge({
    required this.id,
    required this.title,
    required this.category,
    required this.targetSpending,
    required this.completed,
    required this.startTime,
    required this.endTime,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      targetSpending: json['targetSpending'],
      completed: json['completed'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'targetSpending': targetSpending,
      'completed': completed,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
    };
  }
}
