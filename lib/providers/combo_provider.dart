import 'package:flutter/material.dart';
import '../models/farming_models.dart';
import '../services/farming_data_service.dart';

class ComboBuilderProvider with ChangeNotifier {
  FarmingData? _farmingData;
  bool _isLoading = true;
  String? _errorMessage;

  // Selection state
  Crop? _selectedCrop;
  Objective? _selectedObjective;
  Recommendation? _currentRecommendation;

  // Customization
  Map<String, double> _customQuantities = {};
  Set<String> _includedProducts = {}; // Products included in custom combo
  bool _isByAcre = true; // Toggle between acre/pump

  // Maharashtra Agricultural Standards
  static const double pumpsPerAcre = 5.0; // 1 pump covers ~0.2 acres

  // Getters
  FarmingData? get farmingData => _farmingData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Crop? get selectedCrop => _selectedCrop;
  Objective? get selectedObjective => _selectedObjective;
  Recommendation? get currentRecommendation => _currentRecommendation;
  Map<String, double> get customQuantities => _customQuantities;
  bool get isByAcre => _isByAcre;

  ComboBuilderProvider() {
    loadFarmingData();
  }

  Future<void> loadFarmingData() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load farming data from Firebase using FarmingDataService
      _farmingData = await FarmingDataService().loadAllFarmingData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load farming data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback method to load from local assets (for development/testing)
  Future<void> loadFarmingDataFromAssets() async {
    // Keep the original JSON loading as fallback if needed for testing
    // Implementation removed - now only uses Firebase
  }

  void selectCrop(Crop crop) {
    _selectedCrop = crop;
    _selectedObjective = null;
    _currentRecommendation = null;
    notifyListeners();
  }

  void selectObjective(Objective objective) {
    _selectedObjective = objective;
    _currentRecommendation =
        findRecommendation(_selectedCrop!.id, objective.id);
    notifyListeners();
  }

  Recommendation? findRecommendation(String cropId, String objectiveId) {
    if (_farmingData == null) return null;

    try {
      return _farmingData!.recommendations.firstWhere(
        (rec) => rec.cropId == cropId && rec.objectiveId == objectiveId,
      );
    } catch (e) {
      return null;
    }
  }

  FarmingProduct? getProductById(String productId) {
    if (_farmingData == null) return null;

    try {
      return _farmingData!.products.firstWhere(
        (product) => product.id == productId,
      );
    } catch (e) {
      return null;
    }
  }

  void togglePricingMode() {
    _isByAcre = !_isByAcre;
    notifyListeners();
  }

  double calculateTotal() {
    if (_farmingData == null) return 0.0;

    double total = 0.0;

    // Calculate total product purchase cost
    for (final productId in _includedProducts) {
      final product = getProductById(productId);
      if (product != null) {
        final customQty = _customQuantities[productId] ?? 1.0;
        total += customQty * product.price;
      }
    }

    // Apply pricing mode logic based on Maharashtra agricultural practices
    // The quantities entered are treated as "per acre" quantities
    if (_isByAcre) {
      // Per Acre: Show total cost for 1 acre application
      return total;
    } else {
      // Per Pump: Show cost for one pump application = total acre cost ÷ pumps per acre
      return total / pumpsPerAcre;
    }
  }

  void initializeCustomQuantities() {
    if (_currentRecommendation == null) return;

    _customQuantities = {};
    for (final item in _currentRecommendation!.items) {
      _customQuantities[item.productId] = item.qtyAcre;
    }
    notifyListeners();
  }

  void updateCustomQuantity(String productId, double quantity) {
    _customQuantities[productId] = quantity;
    notifyListeners();
  }

  void resetToRecommended() {
    _customQuantities.clear();
    _includedProducts.clear();
    // Re-add the recommended products
    if (_currentRecommendation != null) {
      for (final item in _currentRecommendation!.items) {
        _includedProducts.add(item.productId);
        _customQuantities[item.productId] = item.qtyAcre;
      }
    }
    notifyListeners();
  }

  void initializeCustomProducts() {
    if (_farmingData == null || _currentRecommendation == null) return;

    _includedProducts.clear();
    // Start with all products from the recommendations
    for (final item in _currentRecommendation!.items) {
      _includedProducts.add(item.productId);
    }
    notifyListeners();
  }

  void addProductToCustom(String productId) {
    if (_farmingData == null) return;

    final product = getProductById(productId);
    if (product != null) {
      _includedProducts.add(productId);
      // Add with default quantity (1.0 for kg/litre unit)
      _customQuantities[productId] = 1.0;
      notifyListeners();
    }
  }

  void removeProductFromCustom(String productId) {
    _includedProducts.remove(productId);
    _customQuantities.remove(productId);
    notifyListeners();
  }

  bool isProductInCustom(String productId) {
    return _includedProducts.contains(productId);
  }

  Map<String, List<FarmingProduct>> getProductsGroupedByCategory() {
    if (_currentRecommendation == null || _farmingData == null) {
      return {};
    }

    final Map<String, List<FarmingProduct>> groupedProducts = {};

    for (final item in _currentRecommendation!.items) {
      final product = getProductById(item.productId);
      if (product != null) {
        if (!groupedProducts.containsKey(product.category)) {
          groupedProducts[product.category] = [];
        }
        groupedProducts[product.category]!.add(product);
      }
    }

    return groupedProducts;
  }

  void reset() {
    _selectedCrop = null;
    _selectedObjective = null;
    _currentRecommendation = null;
    _customQuantities.clear();
    _isByAcre = true;
    notifyListeners();
  }
}
