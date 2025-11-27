import 'package:flutter/material.dart';
import '../models/alternative.dart';
import '../repositories/alternative_repository.dart';
import '../api/firestore_client.dart';

class AlternativeProvider with ChangeNotifier {
  List<Alternative> _alternatives = [];
  List<Alternative> _mostViewedAlternatives = [];
  bool _isLoading = false;
  String? _errorMessage;

  // View tracking cache
  Map<String, bool> _viewedAlternatives = {};

  // Getters
  List<Alternative> get alternatives => _alternatives;
  List<Alternative> get mostViewedAlternatives => _mostViewedAlternatives;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AlternativeProvider() {
    loadAlternatives();
  }

  Future<void> loadAlternatives() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final alternativeRepository = AlternativeRepository(FirestoreClient());
      _alternatives = await alternativeRepository.getAllAlternatives();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load alternatives: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMostViewedAlternatives({int limit = 10}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final alternativeRepository = AlternativeRepository(FirestoreClient());
      _mostViewedAlternatives =
          await alternativeRepository.getMostViewedAlternatives(limit: limit);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load popular alternatives: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAlternativesForProduct(String productId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final alternativeRepository = AlternativeRepository(FirestoreClient());
      _alternatives =
          await alternativeRepository.getAlternativesForProduct(productId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load product alternatives: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Alternative?> getAlternativeById(String alternativeId) async {
    try {
      final alternativeRepository = AlternativeRepository(FirestoreClient());
      final alternative =
          await alternativeRepository.getAlternativeById(alternativeId);

      if (alternative != null &&
          !_viewedAlternatives.containsKey(alternativeId)) {
        // Increment view count atomically
        await alternativeRepository.incrementViewCount(alternativeId);

        // Update local cache and increment local view count
        _updateAlternativeViewCountLocally(
            alternativeId, alternative.viewCount + 1);
        _viewedAlternatives[alternativeId] = true;
      }

      return alternative;
    } catch (e) {
      _errorMessage = 'Failed to load alternative: $e';
      return null;
    }
  }

  Future<void> viewAlternative(String alternativeId) async {
    try {
      if (_viewedAlternatives.containsKey(alternativeId)) return;

      final alternativeRepository = AlternativeRepository(FirestoreClient());

      // Increment view count atomically
      await alternativeRepository.incrementViewCount(alternativeId);

      // Update local cache
      _updateAlternativeViewCountLocally(alternativeId);
      _viewedAlternatives[alternativeId] = true;

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to track alternative view: $e';
      notifyListeners();
    }
  }

  void _updateAlternativeViewCountLocally(String alternativeId,
      [int? newViewCount]) {
    final index = _alternatives.indexWhere((alt) => alt.id == alternativeId);
    if (index != -1) {
      final currentViewCount = _alternatives[index].viewCount;
      _alternatives[index] = _alternatives[index].copyWith(
        viewCount: newViewCount ?? (currentViewCount + 1),
      );
    }

    // Also update in most viewed list if present
    final popularIndex =
        _mostViewedAlternatives.indexWhere((alt) => alt.id == alternativeId);
    if (popularIndex != -1) {
      final currentViewCount = _mostViewedAlternatives[popularIndex].viewCount;
      _mostViewedAlternatives[popularIndex] =
          _mostViewedAlternatives[popularIndex].copyWith(
        viewCount: newViewCount ?? (currentViewCount + 1),
      );

      // Re-sort most viewed list
      _mostViewedAlternatives
          .sort((a, b) => b.viewCount.compareTo(a.viewCount));
    }
  }

  bool hasAlternativeBeenViewed(String alternativeId) {
    return _viewedAlternatives[alternativeId] ?? false;
  }

  Alternative? getAlternativeByIdLocally(String alternativeId) {
    try {
      return _alternatives.firstWhere((alt) => alt.id == alternativeId);
    } catch (e) {
      return null;
    }
  }

  List<Alternative> getAlternativesForProductType(String productId) {
    return _alternatives.where((alt) => alt.productId == productId).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _alternatives.clear();
    _mostViewedAlternatives.clear();
    _viewedAlternatives.clear();
    notifyListeners();
  }
}

// Helper extension for Alternative copying (similar to DealExtension)
extension AlternativeExtension on Alternative {
  Alternative copyWith({
    String? id,
    String? productId,
    String? title,
    List<String>? imageUrls,
    double? price,
    double? savings,
    String? chemicalComposition,
    String? modeOfAction,
    String? activeIngredient,
    String? usageDirection,
    List<String>? usedFor,
    int? viewCount,
  }) {
    return Alternative(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      savings: savings ?? this.savings,
      chemicalComposition: chemicalComposition ?? this.chemicalComposition,
      modeOfAction: modeOfAction ?? this.modeOfAction,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      usageDirection: usageDirection ?? this.usageDirection,
      usedFor: usedFor ?? this.usedFor,
      viewCount: viewCount ?? this.viewCount,
    );
  }
}
