import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_btn/loading_btn.dart';
import 'history.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontSize: 18, 
            color: Colors.black,
          ),
        ),
      ),
      home: const CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'THB';
  double _convertedAmount = 0.0;

  final List<String> _currencies = ['USD', 'THB', 'EUR', 'JPY', 'GBP', 'CNY', 'AUD'];

  // รายการประวัติการแปลง
  final List<ConversionHistory> _conversionHistory = [];

  bool validateAmount() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return false;
    }

    double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return false;
    }

    return true;
  }

  Future<void> _convertCurrency() async {
    if (!validateAmount()) return; //Check Amount

    try {
      String apiKey = 'a3b6b0c13f191474740a160a';
      String apiUrl = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/$_fromCurrency';

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        double rate = data['conversion_rates'][_toCurrency];

        // บันทึกการแปลงในประวัติ
        double amount = double.parse(_amountController.text);
        setState(() {
          _convertedAmount = double.parse((amount * rate).toStringAsFixed(2)); // ปัดเป็นทศนิยม 2 ตำแหน่ง
          _conversionHistory.add(ConversionHistory(
            amount: amount,
            fromCurrency: _fromCurrency,
            toCurrency: _toCurrency,
            convertedAmount: _convertedAmount,
            timestamp: DateTime.now(),
          ));
        });
        
        // ตรวจสอบว่าตัววิดเจ็ตยังอยู่ในต้นไม้
        if (!mounted) return; 
        setState(() {
          _convertedAmount = double.parse(_amountController.text) * rate;
        });
      } else {
        throw Exception('Failed to load exchange rate');
      }
    } catch (e) {
      // ตรวจสอบว่าตัววิดเจ็ตยังอยู่ในต้นไม้
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot connect to server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // เปลี่ยนสีพื้นหลังเป็นสีแดง
        title: const Text(
          'Currency Converter',
          style: TextStyle(
            color: Colors.white, // เปลี่ยนสีตัวหนังสือเป็นสีขาว
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversionHistoryPage(history: _conversionHistory),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.blue[50],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: _fromCurrency,
                  onChanged: (value) {
                    setState(() {
                      _fromCurrency = value!;
                    });
                  },
                  items: _currencies.map<DropdownMenuItem<String>>((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                ),
                const Spacer(),
                const Text('to'),
                const Spacer(),
                DropdownButton<String>(
                  value: _toCurrency,
                  onChanged: (value) {
                    setState(() {
                      _toCurrency = value!;
                    });
                  },
                  items: _currencies.map<DropdownMenuItem<String>>((currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LoadingBtn(
              height: 50,
              borderRadius: 8,
              animate: true,
              color: Colors.red,
              width: MediaQuery.of(context).size.width * 0.45,
              loader: Container(
                padding: const EdgeInsets.all(10),
                width: 40,
                height: 40,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              onTap: ((startLoading, stopLoading, btnState) async {
                if (btnState == ButtonState.idle) {
                  startLoading();
                  await Future.delayed(const Duration(seconds: 1));
                  await _convertCurrency();
                  stopLoading();
                }  
              }),
              child: const Text(
                'Convert',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ), // เปลี่ยนสีข้อความเป็นสีขาว
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: _convertedAmount != 0
                        ? 'Converted Amount: '
                        : 'Enter amount and convert',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // สีของข้อความหลัก
                    ),
                  ),
                  TextSpan(
                    text: _convertedAmount != 0
                        ? ' ${_convertedAmount.toStringAsFixed(2)}' // ค่าแปลงเงิน
                        : '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // สีของค่าแปลงเงิน
                    ),
                  ),
                  TextSpan(
                    text: _convertedAmount != 0
                        ? ' $_toCurrency' // สกุลเงิน
                        : '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // สีของสกุลเงิน
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}