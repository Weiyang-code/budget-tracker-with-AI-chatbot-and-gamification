// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Wallet _$WalletFromJson(Map<String, dynamic> json) => Wallet(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  uid: json['uid'] as String? ?? '',
);

Map<String, dynamic> _$WalletToJson(Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
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
  amount: (json['amount'] as num?)?.toInt() ?? 0,
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

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  icon: json['icon'] as String? ?? '',
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'icon': instance.icon,
  'total': instance.total,
};
