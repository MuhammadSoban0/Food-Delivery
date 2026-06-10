import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  static String get publishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static void init() {
    if (publishableKey.isEmpty) {
      debugPrint('❌ Stripe publishable key is empty! Check your .env file.');
      return;
    }
    
    Stripe.publishableKey = publishableKey;
    debugPrint('✅ Stripe initialized with publishable key: ${publishableKey.substring(0, 12)}...');
  }

  static Future<Map<String, dynamic>?> createPaymentIntent({
    required String amount, // amount in cents (e.g., "2000" for $20.00)
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (secretKey.isEmpty) {
        debugPrint('❌ Stripe secret key is empty! Check your .env file.');
        return null;
      }

      debugPrint('🔄 Creating payment intent for amount: $amount cents');
      
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'automatic_payment_methods[enabled]': 'true',
          if (customerId != null) 'customer': customerId,
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value.toString())),
        },
      );

      debugPrint('📡 Payment intent response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Payment intent created successfully');
        return data;
      } else {
        debugPrint('❌ Failed to create payment intent: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error creating payment intent: $e');
      return null;
    }
  }

  static Future<bool> processPayment({
    required BuildContext context,
  }) async {
    try {
      debugPrint('🔄 Presenting payment sheet...');
      
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();
      
      debugPrint('✅ Payment completed successfully');
      return true;
    } on StripeException catch (e) {
      debugPrint('❌ Stripe error: ${e.error}');
      
      // Don't show error for user cancellation
      if (e.error.code == FailureCode.Canceled) {
        debugPrint('💡 Payment was cancelled by user');
        return false;
      }
      
      // Show error to user for other cases
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    } catch (e) {
      debugPrint('❌ General payment error: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed: Unknown error'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  static Future<bool> initializePaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
  }) async {
    try {
      if (paymentIntentClientSecret.isEmpty) {
        debugPrint('❌ Payment intent client secret is empty');
        return false;
      }

      debugPrint('🔄 Initializing payment sheet...');
      debugPrint('Client secret: ${paymentIntentClientSecret.substring(0, 20)}...');
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: merchantDisplayName,
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color(0xFFE53E3E), // Your app's red color
                ),
              ),
            ),
          ),
        ),
      );
      
      debugPrint('✅ Payment sheet initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing payment sheet: $e');
      debugPrint('❌ Error type: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }
}