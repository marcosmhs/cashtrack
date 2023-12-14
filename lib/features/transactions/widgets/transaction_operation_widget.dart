import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class TransactionOperationWidget extends StatefulWidget {
  final TransactionOperation operation;
  final void Function(TransactionOperation operation) onSelect;
  const TransactionOperationWidget({super.key, required this.operation, required this.onSelect});

  @override
  State<TransactionOperationWidget> createState() => _TransactionOperationWidgetState();
}

class _TransactionOperationWidgetState extends State<TransactionOperationWidget> {
  var _isInitializing = true;
  List<bool> selected = [true, false];
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      selected = [widget.operation == TransactionOperation.negative, widget.operation == TransactionOperation.positive];
      _isInitializing = false;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: TebText(
              'Tipo de operação',
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(height: 40),
              child: ToggleButtons(
                isSelected: selected,
                selectedColor: Theme.of(context).colorScheme.primary,
                onPressed: (index) {
                  widget.onSelect(index == 0 ? TransactionOperation.negative : TransactionOperation.positive);
                  setState(() => selected = [index == 0, index == 1]);
                },
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TebText(
                      Transaction.transactionOperationText(TransactionOperation.negative),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: TebText(
                      Transaction.transactionOperationText(TransactionOperation.positive),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
