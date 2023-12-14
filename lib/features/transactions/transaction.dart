import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:teb_package/teb_package.dart';

enum TransactionOperation { positive, negative }

class Transaction {
  late String id;
  late DateTime? date;
  late String userId;
  late String walletId;
  late double value;
  late TransactionOperation operation;
  late String description;
  late bool recurring;
  late bool active;
  late String transactionTypeId;
  late String transactionTypeName;
  late String transactionGroupId;
  late String transactionGroupName;
  late TransactionType transactionType;
  late TransactionGroup transactionGroup;

  static IconData get icon => FontAwesomeIcons.trainSubway;
  static IconData get transactionOperationNegativeIcon => FontAwesomeIcons.minus;
  static IconData get transactionOperationPositiveIcon => FontAwesomeIcons.plus;

  static final Color _transactionOperationNegative = TebUtil.hexStringToColor("#ff53dbc9");
  static final Color _transactionOperationPositive = TebUtil.hexStringToColor("#ffffffff");

  Transaction({
    this.id = '',
    this.userId = '',
    this.walletId = '',
    this.date,
    this.value = 0,
    this.operation = TransactionOperation.negative,
    this.description = '',
    this.recurring = false,
    this.active = true,
    this.transactionTypeId = '',
    this.transactionTypeName = '',
    TransactionType? transactionType,
    this.transactionGroupId = '',
    this.transactionGroupName = '',
    TransactionGroup? transactionGroup,
  }) {
    this.transactionGroup = transactionGroup ?? TransactionGroup();
    this.transactionType = transactionType ?? TransactionType();
  }

  factory Transaction.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Transaction.fromMap(data);
  }

  void setTransactionType(TransactionType transactionType) {
    transactionTypeId = transactionType.id;
    transactionTypeName = transactionType.name;
    this.transactionType = transactionType;
  }

  void setTransactionGroup(TransactionGroup transactionGroup) {
    transactionGroupId = transactionGroup.id;
    transactionGroupName = transactionGroup.name;
    this.transactionGroup = transactionGroup;
    transactionTypeId = transactionGroup.transactionType.id;
    transactionTypeName = transactionGroup.transactionType.name;
    transactionType = transactionGroup.transactionType;
  }

  String formatedValue({bool showOperationSignal = true}) {
    final currency = NumberFormat.currency(
      locale: 'pt-BR',
      customPattern: '#,### \u00a4',
      symbol: '',
      decimalDigits: 2,
    );

    var formatedValue = "R\$ ${currency.format(value)}";

    if (showOperationSignal) {
      formatedValue = '${transactionOperationSignal(operation)} $formatedValue';
    }

    return formatedValue;
  }

  Color get transactionOperationFontColor =>
      operation == TransactionOperation.negative ? _transactionOperationNegative : _transactionOperationPositive;

  static String transactionOperationSignal(TransactionOperation operation) =>
      operation == TransactionOperation.negative ? '(-)' : '(+)';

  static transactionOperationFromString(String value) =>
      value == TransactionOperation.negative.toString() ? TransactionOperation.negative : TransactionOperation.positive;

  static String transactionOperationText(TransactionOperation operation) =>
      operation == TransactionOperation.negative ? 'Despesa (-)' : 'Recebimento (+)';

  static Transaction fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      walletId: map['walletId'] ?? '',
      date: map['date'] == null ? DateTime.now() : DateTime.tryParse(map['date']),
      value: map['value'] ?? '',
      operation: Transaction.transactionOperationFromString(map['operation'] ?? ''),
      description: map['description'] ?? '',
      recurring: map['recurring'] ?? false,
      active: map['active'] ?? true,
      transactionTypeId: map['transactionTypeId'] ?? '',
      transactionTypeName: map['transactionTypeName'] ?? '',
      transactionGroupId: map['transactionGroupId'] ?? '',
      transactionGroupName: map['transactionGroupName'] ?? '',
    );
  }

  Map<String, dynamic> get toMap {
    return {
      'id': id,
      'userId': userId,
      'walletId': walletId,
      'date': date.toString(),
      'value': value,
      'operation': operation.toString(),
      'description': description,
      'recurring': recurring,
      'active': active,
      'transactionTypeId': transactionTypeId,
      'transactionTypeName': transactionTypeName,
      'transactionGroupId': transactionGroupId,
      'transactionGroupName': transactionGroupName,
    };
  }
}
