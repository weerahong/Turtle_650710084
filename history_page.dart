import 'package:flutter/material.dart';
import 'history.dart';

class ConversionHistoryPage extends StatelessWidget {
  final List<ConversionHistory> history;

  const ConversionHistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion history'),
      ),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final record = history[index];
          return ListTile(
            title: Text('${record.amount} ${record.fromCurrency} = ${record.convertedAmount} ${record.toCurrency}'),
            subtitle: Text('Date: ${record.timestamp}'),
          );
        },
      ),
    );
  }
}
