import '../api/firestore_client.dart';
import '../models/farming_models.dart';
import '../repositories/crop_repository.dart';
import '../repositories/objective_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_repository.dart';

class FarmingDataService {
  static final FarmingDataService _instance = FarmingDataService._internal();

  factory FarmingDataService() => _instance;

  FarmingDataService._internal({
    FirestoreClient? firestoreClient,
  }) : _firestoreClient = firestoreClient ?? FirestoreClient() {
    _cropRepository = CropRepository(_firestoreClient);
    _objectiveRepository = ObjectiveRepository(_firestoreClient);
    _productRepository = ProductRepository(_firestoreClient);
    _recommendationRepository = RecommendationRepository(_firestoreClient);
  }

  final FirestoreClient _firestoreClient;
  late final CropRepository _cropRepository;
  late final ObjectiveRepository _objectiveRepository;
  late final ProductRepository _productRepository;
  late final RecommendationRepository _recommendationRepository;

  // Crops
  Future<List<Crop>> getAllCrops() => _cropRepository.getAllCrops();
  Stream<List<Crop>> watchAllCrops() => _cropRepository.watchAllCrops();
  Future<Crop?> getCropById(String cropId) =>
      _cropRepository.getCropById(cropId);
  Stream<Crop?> watchCropById(String cropId) =>
      _cropRepository.watchCropById(cropId);

  // Objectives
  Future<List<Objective>> getAllObjectives() =>
      _objectiveRepository.getAllObjectives();
  Stream<List<Objective>> watchAllObjectives() =>
      _objectiveRepository.watchAllObjectives();
  Future<Objective?> getObjectiveById(String objectiveId) =>
      _objectiveRepository.getObjectiveById(objectiveId);
  Stream<Objective?> watchObjectiveById(String objectiveId) =>
      _objectiveRepository.watchObjectiveById(objectiveId);

  // Products
  Future<List<FarmingProduct>> getAllProducts() =>
      _productRepository.getAllProducts();
  Stream<List<FarmingProduct>> watchAllProducts() =>
      _productRepository.watchAllProducts();
  Future<FarmingProduct?> getProductById(String productId) =>
      _productRepository.getProductById(productId);
  Stream<FarmingProduct?> watchProductById(String productId) =>
      _productRepository.watchProductById(productId);
  Future<List<FarmingProduct>> getProductsByCategory(String category) =>
      _productRepository.getProductsByCategory(category);
  Future<List<FarmingProduct>> searchProducts(String query) =>
      _productRepository.searchProducts(query);

  // Recommendations
  Future<List<Recommendation>> getAllRecommendations() =>
      _recommendationRepository.getAllRecommendations();
  Future<Recommendation?> getRecommendationByCropAndObjective(
    String cropId,
    String objectiveId,
  ) =>
      _recommendationRepository.getRecommendationByCropAndObjective(
          cropId, objectiveId);
  Future<List<Recommendation>> getRecommendationsForCrop(String cropId) =>
      _recommendationRepository.getRecommendationsForCrop(cropId);

  /// Combined data loading - loads all farming data at once
  Future<FarmingData> loadAllFarmingData() async {
    final results = await Future.wait([
      getAllCrops(),
      getAllObjectives(),
      getAllProducts(),
      getAllRecommendations(),
    ]);

    return FarmingData(
      crops: results[0] as List<Crop>,
      objectives: results[1] as List<Objective>,
      products: results[2] as List<FarmingProduct>,
      recommendations: results[3] as List<Recommendation>,
    );
  }

  /// Get recommendation with product details
  Future<Map<String, dynamic>?> getRecommendationWithProducts(
    String cropId,
    String objectiveId,
  ) async {
    final recommendation =
        await getRecommendationByCropAndObjective(cropId, objectiveId);
    if (recommendation == null) return null;

    // Load all products used in the recommendation
    final productIds =
        recommendation.items.map((item) => item.productId).toSet();
    final products = <FarmingProduct>[];

    for (final productId in productIds) {
      final product = await getProductById(productId);
      if (product != null) {
        products.add(product);
      }
    }

    return {
      'recommendation': recommendation,
      'products': products,
    };
  }
}
