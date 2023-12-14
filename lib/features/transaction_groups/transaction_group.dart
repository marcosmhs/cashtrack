import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionGroup {
  late String id;
  late String name;
  late String walletId;
  late bool active;
  late String transactionTypeId;
  late String transactionTypeName;
  late TransactionType transactionType;

  static IconData get icon => FontAwesomeIcons.groupArrowsRotate;

  TransactionGroup({
    this.id = '',
    this.name = '',
    this.walletId = '',
    this.active = true,
    this.transactionTypeId = '',
    this.transactionTypeName = '',
    TransactionType? transactionType,
  }) {
    this.transactionType = transactionType ?? TransactionType();
  }

  factory TransactionGroup.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TransactionGroup.fromMap(data);
  }

  void setTransactionType(TransactionType transactionType) {
    transactionTypeId = transactionType.id;
    transactionTypeName = transactionType.name;
    this.transactionType = transactionType;
  }

  static TransactionGroup fromMap(Map<String, dynamic> map) {
    return TransactionGroup(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      walletId: map['walletId'] ?? '',
      active: map['active'] ?? true,
      transactionTypeId: map['transactionTypeId'] ?? '',
      transactionTypeName: map['transactionTypeName'] ?? '',
    );
  }

  Map<String, dynamic> get toMap {
    return {
      'id': id,
      'name': name,
      'walletId': walletId,
      'active': active,
      'transactionTypeId': transactionTypeId,
      'transactionTypeName': transactionTypeName,
    };
  }
}
