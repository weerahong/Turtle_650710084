import 'package:flutter/material.dart';

class ConversionHistory {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double convertedAmount;
  final DateTime timestamp;

  ConversionHistory({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.convertedAmount,
    required this.timestamp,
  });
}

class ConversionHistoryPage extends StatefulWidget {
  final List<ConversionHistory> history;

  const ConversionHistoryPage({super.key, required this.history});

  @override
  // ignore: library_private_types_in_public_api
  _ConversionHistoryPageState createState() => _ConversionHistoryPageState();
}

class _ConversionHistoryPageState extends State<ConversionHistoryPage> {
  void _clearHistory() {
    setState(() {
      widget.history.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // เปลี่ยนสีพื้นหลังเป็นสีแดง
        title: const  Text(
          'Conversion History',
          style: TextStyle(
            color: Colors.white, // เปลี่ยนสีตัวหนังสือเป็นสีขาว
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: widget.history.isEmpty
          ? const Center(child: Text('No conversion history'))
          : ListView.builder(
              itemCount: widget.history.length,
              itemBuilder: (context, index) {
                final historyItem = widget.history[index];
                return ListTile(
                  title: Text(
                      '${historyItem.amount} ${historyItem.fromCurrency} -> ${historyItem.convertedAmount.toStringAsFixed(2)} ${historyItem.toCurrency}'),
                  subtitle: Text(
                      'Date: ${historyItem.timestamp.toLocal().toString().split(' ')[0]}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearHistory,
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white,),
      ),
    );
  }
}
