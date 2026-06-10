import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeDebug {
  static void validateConfiguration() {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    final secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
    
    debugPrint('=== STRIPE CONFIGURATION DEBUG ===');
    
    if (publishableKey.isEmpty) {
      debugPrint('❌ STRIPE_PUBLISHABLE_KEY is empty or not found in .env');
    } else if (publishableKey.startsWith('pk_test_')) {
      debugPrint('✅ STRIPE_PUBLISHABLE_KEY found (TEST mode)');
      debugPrint('   Key: ${publishableKey.substring(0, 20)}...');
    } else if (publishableKey.startsWith('pk_live_')) {
      debugPrint('✅ STRIPE_PUBLISHABLE_KEY found (LIVE mode)');
      debugPrint('   Key: ${publishableKey.substring(0, 20)}...');
    } else {
      debugPrint('⚠️  STRIPE_PUBLISHABLE_KEY format might be incorrect');
      debugPrint('   Key: ${publishableKey.substring(0, 20)}...');
    }
    
    if (secretKey.isEmpty) {
      debugPrint('❌ STRIPE_SECRET_KEY is empty or not found in .env');
    } else if (secretKey.startsWith('sk_test_')) {
      debugPrint('✅ STRIPE_SECRET_KEY found (TEST mode)');
      debugPrint('   Key: ${secretKey.substring(0, 20)}...');
    } else if (secretKey.startsWith('sk_live_')) {
      debugPrint('✅ STRIPE_SECRET_KEY found (LIVE mode)');
      debugPrint('   Key: ${secretKey.substring(0, 20)}...');
    } else {
      debugPrint('⚠️  STRIPE_SECRET_KEY format might be incorrect');
      debugPrint('   Key: ${secretKey.substring(0, 20)}...');
    }
    
    debugPrint('===============================');
  }
}