enum PaymentGateway { stripe, paypal, razorpay, flutterwave, paystack }

class PaymentService {
  Future<void> processPayment(PaymentGateway gateway, double amount) async {
    switch (gateway) {
      case PaymentGateway.stripe:
        await _payWithStripe(amount);
        break;
      case PaymentGateway.paypal:
        await _payWithPayPal(amount);
        break;
      case PaymentGateway.razorpay:
        await _payWithRazorpay(amount);
        break;
      case PaymentGateway.flutterwave:
        await _payWithFlutterwave(amount);
        break;
      case PaymentGateway.paystack:
        await _payWithPaystack(amount);
        break;
    }
  }

  Future<void> _payWithStripe(double amount) async {
    // Thêm logic thanh toán bằng Stripe ở đây
  }

  Future<void> _payWithPayPal(double amount) async {
    // Thêm logic thanh toán bằng PayPal ở đây
  }

  Future<void> _payWithRazorpay(double amount) async {
    // Thêm logic thanh toán bằng Razorpay ở đây
  }

  Future<void> _payWithFlutterwave(double amount) async {
    // Thêm logic thanh toán bằng Flutterwave ở đây
  }

  Future<void> _payWithPaystack(double amount) async {
    // Thêm logic thanh toán bằng Paystack ở đây
  }
}
