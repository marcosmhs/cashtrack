import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TransactionType {
  late String id;
  late String walletId;
  late String name;
  late bool active;
  late TransactionOperation operation;

  static IconData get icon => FontAwesomeIcons.typo3;

  TransactionType({
    this.id = '',
    this.walletId = '',
    this.name = '',
    this.active = true,
    this.operation = TransactionOperation.negative,
  });

  factory TransactionType.fromDocument(fb.DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return TransactionType.fromMap(data);
  }

  static TransactionType fromMap(Map<String, dynamic> map) {
    return TransactionType(
      id: map['id'] ?? '',
      walletId: map['walletId'] ?? '',
      name: map['name'] ?? '',
      active: map['active'] ?? true,
      operation: Transaction.transactionOperationFromString(map['operation'] ?? ''),
    );
  }

  Map<String, dynamic> get toMap {
    return {
      'id': id,
      'walletId': walletId,
      'name': name,
      'active': active,
      'operation': operation.toString(),
    };
  }
}
