import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constant/api_constant.dart';
import 'supabase_service.dart';

/// Thrown when a Google Play purchase fails or is cancelled. [canceled] lets
/// the UI stay quiet for a user-initiated cancel instead of showing an error.
class PurchaseException implements Exception {
  final String message;
  final bool canceled;
  PurchaseException(this.message, {this.canceled = false});

  @override
  String toString() => message;
}

/// Google Play Billing for the coin packs and Extra Mining Time (consumable
/// in-app products). Every purchase is verified, granted and consumed
/// server-side by verify-play-purchase - the app never grants anything itself.
class PlayBillingService {
  PlayBillingService._();
  static final PlayBillingService instance = PlayBillingService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Map<String, ProductDetails> _products = {};

  /// The purchase the UI is currently waiting on, keyed by Play product id.
  final Map<String, Completer<bool>> _waiting = {};
  final Map<String, String?> _sessionIds = {};

  /// Starts listening for purchase updates. Safe to call more than once.
  void init() {
    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) => debugPrint('Play purchase stream error: $e'),
    );
  }

  /// Re-delivers purchases that were paid for but never granted (app killed
  /// mid-purchase, no network) so they get verified now. Call once signed in.
  Future<void> recoverUnfinishedPurchases() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    try {
      if (!await _iap.isAvailable()) return;
      init();
      await _iap.restorePurchases(applicationUserName: userId);
    } catch (e) {
      debugPrint('Recovering Play purchases failed: $e');
    }
  }

  /// Play's localized details (price in the player's currency) for [ids].
  /// Products missing from Play Console are just left out.
  Future<Map<String, ProductDetails>> loadProducts(Set<String> ids) async {
    final missing = ids.difference(_products.keys.toSet());
    if (missing.isNotEmpty && await _iap.isAvailable()) {
      final response = await _iap.queryProductDetails(missing);
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Play products not found: ${response.notFoundIDs}');
      }
    }
    return {for (final id in ids) if (_products[id] != null) id: _products[id]!};
  }

  /// Buys [productId] and resolves once the server has granted it.
  /// [sessionId] goes with an Extra Mining Time purchase.
  Future<bool> buy(String productId, {String? sessionId}) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) throw PurchaseException('Please log in again.');
    if (!await _iap.isAvailable()) {
      throw PurchaseException('Google Play is not available on this device.');
    }
    init();

    final product = (await loadProducts({productId}))[productId];
    if (product == null) throw PurchaseException('This item is not available right now.');

    final completer = Completer<bool>();
    _waiting[productId] = completer;
    _sessionIds[productId] = sessionId;

    final started = await _iap.buyConsumable(
      // The Supabase user id becomes Play's obfuscated account id, so the
      // server can check the token really belongs to this player.
      purchaseParam: PurchaseParam(productDetails: product, applicationUserName: userId),
      // verify-play-purchase consumes it after granting.
      autoConsume: false,
    );
    if (!started) {
      _waiting.remove(productId);
      throw PurchaseException('Could not start the purchase.');
    }
    return completer.future;
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      final waiter = _waiting[purchase.productID];
      switch (purchase.status) {
        case PurchaseStatus.pending:
          // e.g. a slow UPI payment - Play delivers it again once it clears.
          break;
        case PurchaseStatus.canceled:
          _finish(purchase.productID, error: PurchaseException('Purchase cancelled', canceled: true));
          await _complete(purchase);
        case PurchaseStatus.error:
          _finish(
            purchase.productID,
            error: PurchaseException(purchase.error?.message ?? 'Payment failed'),
          );
          await _complete(purchase);
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          try {
            await SupabaseService.invoke(
              ApiConstant.fnVerifyPlayPurchase,
              body: {
                'product_id': purchase.productID,
                'purchase_token': purchase.verificationData.serverVerificationData,
                if (_sessionIds[purchase.productID] != null) 'session_id': _sessionIds[purchase.productID],
              },
            );
            await _complete(purchase);
            _finish(purchase.productID, granted: true);
          } catch (e) {
            // Left unfinished on purpose: recoverUnfinishedPurchases retries it.
            debugPrint('verify-play-purchase failed: $e');
            if (waiter != null) _finish(purchase.productID, error: PurchaseException('$e'));
          }
      }
    }
  }

  Future<void> _complete(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(purchase);
    } catch (e) {
      // Already consumed server-side, which also acknowledges it.
      debugPrint('completePurchase: $e');
    }
  }

  void _finish(String productId, {bool granted = false, PurchaseException? error}) {
    _sessionIds.remove(productId);
    final completer = _waiting.remove(productId);
    if (completer == null || completer.isCompleted) return;
    if (error != null) {
      completer.completeError(error);
    } else {
      completer.complete(granted);
    }
  }
}
