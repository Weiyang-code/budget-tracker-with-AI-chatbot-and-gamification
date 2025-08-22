// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  balance: (json['balance'] as num?)?.toDouble() ?? 0,
  uid: json['uid'] as String? ?? '',
  type: json['type'] as String? ?? '',
  currency: json['currency'] as String? ?? '',
);

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'currency': instance.currency,
  'balance': instance.balance,
  'uid': instance.uid,
};

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  uid: json['uid'] as String? ?? '',
  walletId: json['walletId'] as String? ?? '',
  date: _$JsonConverterFromJson<Object, Timestamp>(
    json['date'],
    const TimestampConverter().fromJson,
  ),
  amount: (json['amount'] as num?)?.toDouble() ?? 0,
  category: json['category'] as String? ?? '',
  note: json['note'] as String? ?? '',
  type: json['type'] as String? ?? 'expense',
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'walletId': instance.walletId,
      'date': const TimestampConverter().toJson(instance.date),
      'amount': instance.amount,
      'category': instance.category,
      'note': instance.note,
      'type': instance.type,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  id: json['id'] as String? ?? '',
  uid: json['uid'] as String? ?? '',
  category: json['category'] as String? ?? '',
  amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
  spending: (json['spending'] as num?)?.toDouble() ?? 0.0,
  startTime: _$JsonConverterFromJson<Object, Timestamp>(
    json['startTime'],
    const TimestampConverter().fromJson,
  ),
  endTime: _$JsonConverterFromJson<Object, Timestamp>(
    json['endTime'],
    const TimestampConverter().fromJson,
  ),
  createdAt: _$JsonConverterFromJson<Object, Timestamp>(
    json['createdAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'uid': instance.uid,
  'category': instance.category,
  'amount': instance.amount,
  'spending': instance.spending,
  'startTime': const TimestampConverter().toJson(instance.startTime),
  'endTime': const TimestampConverter().toJson(instance.endTime),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
  id: json['id'] as String,
  budgetId: json['budgetId'] as String,
  title: json['title'] as String,
  category: json['category'] as String,
  targetSpending: (json['targetSpending'] as num).toDouble(),
  completed: json['completed'] as bool,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
);

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
  'id': instance.id,
  'budgetId': instance.budgetId,
  'title': instance.title,
  'category': instance.category,
  'targetSpending': instance.targetSpending,
  'completed': instance.completed,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
};
