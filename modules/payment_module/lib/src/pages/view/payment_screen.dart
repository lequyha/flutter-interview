import 'package:flutter/material.dart';
import 'package:payment_module/src/services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const PaymentScreen());
  }

  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentGateway? _selectedGateway;

  void _onPaymentSelected(PaymentGateway gateway) {
    setState(() {
      _selectedGateway = gateway;
    });
  }

  void _processPayment() {
    if (_selectedGateway == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng chọn phương thức thanh toán")),
      );
      return;
    }

    // Thực hiện logic thanh toán dựa trên gateway được chọn
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Thanh toán qua ${_selectedGateway!.name}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn Phương Thức Thanh Toán")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children:
                  PaymentGateway.values.map((gateway) {
                    return ListTile(
                      title: Text(gateway.name.toUpperCase()),
                      leading: Radio<PaymentGateway>(
                        value: gateway,
                        groupValue: _selectedGateway,
                        onChanged: (PaymentGateway? value) {
                          _onPaymentSelected(value!);
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _processPayment,
              child: Text("Thanh Toán"),
            ),
          ),
        ],
      ),
    );
  }
}
