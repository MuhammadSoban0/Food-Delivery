import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import '../../core/app_state.dart';
import '../../services/stripe_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final state = context.read<AppState>();
      final double subtotal = state.cartSubtotal;
      const double delivery = 5.00;
      final double total = subtotal + delivery;
      
      // Convert to cents for Stripe (multiply by 100)
      final String amountInCents = (total * 100).round().toString();

      debugPrint('🛒 Processing payment for total: \$${total.toStringAsFixed(2)} ($amountInCents cents)');

      // Create payment intent
      final paymentIntent = await StripeService.createPaymentIntent(
        amount: amountInCents,
        currency: 'usd',
        metadata: {
          'order_type': 'grocery_delivery',
          'item_count': state.cartItems.length.toString(),
          'total_amount': total.toStringAsFixed(2),
        },
      );

      if (paymentIntent == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize payment. Please check your internet connection and try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      final clientSecret = paymentIntent['client_secret'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid payment configuration. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Initialize payment sheet
      final success = await StripeService.initializePaymentSheet(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Foodgo Grocery Delivery',
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize payment sheet. Please try again or contact support.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      // Process payment
      final paymentSuccess = await StripeService.processPayment(
        context: context,
      );

      if (paymentSuccess && mounted) {
        // Payment successful
        context.read<AppState>().addNotification(
          title: 'Payment Successful! 🎉',
          body: 'Your grocery order has been confirmed and is being prepared for delivery.',
        );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OrderSuccessDialog(),
        );
      }
    } catch (e) {
      debugPrint('❌ Payment processing error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cartItems = state.cartItems;
    final double subtotal = state.cartSubtotal;
    const double delivery = 5.00;
    final double total = subtotal + delivery;

    // Group items for summary
    final Map<String, int> quantityMap = {};
    for (var item in cartItems) {
      if (quantityMap.containsKey(item.id)) {
        quantityMap[item.id] = quantityMap[item.id]! + 1;
      } else {
        quantityMap[item.id] = 1;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.chevron_left)),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x21000000),
                      blurRadius: 17,
                      offset: Offset(0, 6),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    ...quantityMap.entries.map((entry) {
                      final item = cartItems.firstWhere(
                        (p) => p.id == entry.key,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${entry.value}x ${item.name}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '\$${(item.price * entry.value).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Payment Details Section
              const Spacer(),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Pay \$${total.toStringAsFixed(2)} with Stripe',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required String hint,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 8,
                offset: Offset(0, 2),
                spreadRadius: 0,
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            obscureText: isPassword,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.grey, size: 20),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 &&
          nonZeroIndex != text.length &&
          nonZeroIndex == 2) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class OrderSuccessDialog extends StatelessWidget {
  const OrderSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                color: Colors.green,
                size: 60,
              ),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your groceries are on the way. Sit back and relax!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().clearCart();
                  // Pop dialog
                  Navigator.of(context).pop();
                  // Pop checkout screen, returning to main screen
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
