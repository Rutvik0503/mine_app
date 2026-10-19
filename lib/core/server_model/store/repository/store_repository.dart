import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../services/play_billing_service.dart';
import '../model/purchase_model.dart';
import '../model/store_package_model.dart';
import '../service/store_service.dart';

export '../../../services/play_billing_service.dart' show PurchaseException;

class StoreRepository {
  final StoreService _service = StoreService();

  Future<List<StorePackageModel>> packages() => _service.fetchPackages();

  Future<StorePackageModel?> sessionExtensionPackage() => _service.fetchSessionExtensionPackage();

  Future<List<PurchaseModel>> history() => _service.fetchHistory();

  /// Play's localized details for [packages] (missing ones are left out).
  Future<Map<String, ProductDetails>> playProducts(List<StorePackageModel> packages) {
    final ids = packages.map((p) => p.playProductId).whereType<String>().toSet();
    return PlayBillingService.instance.loadProducts(ids);
  }

  /// Buys [package] through Google Play. Resolves true once
  /// verify-play-purchase has granted it; throws [PurchaseException] on
  /// failure or cancel. [sessionId] goes with an Extra Mining Time package.
  Future<bool> purchase(StorePackageModel package, {String? sessionId}) {
    final productId = package.playProductId;
    if (productId == null) throw PurchaseException('This item is not available right now.');
    return PlayBillingService.instance.buy(productId, sessionId: sessionId);
  }
}
