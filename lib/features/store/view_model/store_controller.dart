import 'package:get/get.dart';
import '../../../core/common_widget/app_snackbar.dart';
import '../../../core/server_model/store/model/store_package_model.dart';
import '../../../core/server_model/store/repository/store_repository.dart';

class StoreController extends GetxController {
  final StoreRepository _storeRepository = StoreRepository();

  final isLoading = true.obs;
  final purchasingId = Rxn<String>();
  final packages = <StorePackageModel>[].obs;

  /// Play's localized price per product id (falls back to our own label).
  final playPrices = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      packages.value = await _storeRepository.packages();
      final products = await _storeRepository.playProducts(packages);
      playPrices.value = {for (final e in products.entries) e.key: e.value.price};
    } catch (_) {
      // Prices fall back to our own labels; buying still checks with Play.
    } finally {
      isLoading.value = false;
    }
  }

  String priceFor(StorePackageModel package) =>
      playPrices[package.playProductId] ?? package.priceLabel;

  Future<void> buy(StorePackageModel package) async {
    if (purchasingId.value != null) return;
    purchasingId.value = package.id;
    try {
      final granted = await _storeRepository.purchase(package);
      if (granted) {
        AppSnackbar.success('pointsAdded'.trParams({'value': package.points.toStringAsFixed(0)}));
      }
    } on PurchaseException catch (e) {
      if (!e.canceled) AppSnackbar.error(e.message);
    } catch (e) {
      AppSnackbar.error('purchaseFailed'.trParams({'error': '$e'}));
    } finally {
      purchasingId.value = null;
    }
  }
}
