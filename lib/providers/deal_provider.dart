import 'package:flutter/material.dart';
import '../models/deal.dart';
import '../repositories/deal_repository.dart';
import '../repositories/user_repository.dart';
import '../api/firestore_client.dart';

class DealProvider with ChangeNotifier {
  List<Deal> _deals = [];
  List<Deal> _activeDeals = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Participant tracking
  Map<String, bool> _participationStatus = {};

  // Getters
  List<Deal> get deals => _deals;
  List<Deal> get activeDeals => _activeDeals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DealProvider() {
    loadDeals();
  }

  Future<void> loadDeals() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dealRepository = DealRepository(FirestoreClient());
      _deals = await dealRepository.getAllDeals();
      _activeDeals = _deals
          .where((deal) => deal.current_participants < deal.min_participants)
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load deals: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadActiveDeals() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dealRepository = DealRepository(FirestoreClient());
      _activeDeals = await dealRepository.getActiveDeals();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load active deals: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> participateInDeal(String dealId, String userId) async {
    try {
      final dealRepository = DealRepository(FirestoreClient());
      final userRepository = UserRepository(FirestoreClient());

      // Perform atomic deal participation update
      await dealRepository.participateInDeal(dealId, userId);

      // Update user profile with participated deal
      await userRepository.addParticipatedDeal(userId, dealId);

      // Update local data
      final dealIndex = _deals.indexWhere((deal) => deal.id == dealId);
      if (dealIndex != -1) {
        _deals[dealIndex] = _deals[dealIndex].copyWith(
          current_participants: _deals[dealIndex].current_participants + 1,
        );

        // Update active deals if necessary
        if (_deals[dealIndex].current_participants >=
            _deals[dealIndex].min_participants) {
          _activeDeals.removeWhere((deal) => deal.id == dealId);
        } else {
          // Update the active deals list
          final activeIndex =
              _activeDeals.indexWhere((deal) => deal.id == dealId);
          if (activeIndex != -1) {
            _activeDeals[activeIndex] = _deals[dealIndex];
          }
        }
      }

      _participationStatus[dealId] = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to participate in deal: $e';
      notifyListeners();
    }
  }

  Future<void> loadUserParticipatedDeals(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dealRepository = DealRepository(FirestoreClient());
      _deals = await dealRepository.getUserParticipatedDeals(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load participated deals: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasUserParticipated(String dealId) {
    return _participationStatus[dealId] ?? false;
  }

  Deal? getDealById(String dealId) {
    try {
      return _deals.firstWhere((deal) => deal.id == dealId);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _deals.clear();
    _activeDeals.clear();
    _participationStatus.clear();
    notifyListeners();
  }
}

// Helper extension for Deal copying (similar to UserDetails)
extension DealExtension on Deal {
  Deal copyWith({
    String? id,
    String? title,
    String? description,
    double? mrp,
    double? deal_price,
    int? min_participants,
    int? current_participants,
    String? status,
    double? progress_percentage,
    List<String>? images,
  }) {
    return Deal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mrp: mrp ?? this.mrp,
      deal_price: deal_price ?? this.deal_price,
      min_participants: min_participants ?? this.min_participants,
      current_participants: current_participants ?? this.current_participants,
      status: status ?? this.status,
      progress_percentage: progress_percentage ?? this.progress_percentage,
      images: images ?? this.images,
    );
  }
}
