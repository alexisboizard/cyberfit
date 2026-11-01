import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../core/constants/app_constants.dart';

class PurchaseService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    final apiKey = Platform.isIOS
        ? AppConstants.revenueCatAppleApiKey
        : AppConstants.revenueCatGoogleApiKey;

    if (apiKey.isEmpty || apiKey.startsWith('your_')) return;

    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;
  }

  static Future<void> login(String uid) async {
    if (!_initialized) return;
    await Purchases.logIn(uid);
  }

  static Future<void> logout() async {
    if (!_initialized) return;
    await Purchases.logOut();
  }

  static Future<Offerings?> getOfferings() async {
    if (!_initialized) return null;
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> purchasePackage(Package package) async {
    if (!_initialized) return false;
    try {
      final result = await Purchases.purchasePackage(package);
      return result.entitlements.all[AppConstants.premiumEntitlementId]
              ?.isActive ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restorePurchases() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.restorePurchases();
      return info.entitlements.all[AppConstants.premiumEntitlementId]
              ?.isActive ??
          false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkPremiumStatus() async {
    if (!_initialized) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.all[AppConstants.premiumEntitlementId]
              ?.isActive ??
          false;
    } catch (_) {
      return false;
    }
  }
}
