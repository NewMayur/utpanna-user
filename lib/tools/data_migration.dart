import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import '../api/firestore_client.dart';
import '../api/collections.dart';
import '../models/farming_models.dart';
import '../models/deal.dart';
import '../models/alternative.dart';
import '../repositories/deal_repository.dart';
import '../repositories/alternative_repository.dart';
import '../repositories/crop_repository.dart';
import '../repositories/objective_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_repository.dart';
import '../utils/firebase_config.dart';

class DataMigration {
  final FirestoreClient _client;

  DataMigration(this._client);

  /// Main migration method - runs full migration
  Future<Map<String, dynamic>> migrateAllData() async {
    final results = <String, dynamic>{};
    int totalMigrated = 0;

    print('\n🚀 Starting Complete Data Migration to Firebase...\n');

    try {
      // Migrate farming data
      print('🌱 Phase 1: Migrating Farming Data...');
      final farmingResults = await migrateFarmingData();
      if (!farmingResults['success']) {
        throw Exception('Farming migration failed: ${farmingResults['error']}');
      }

      // Merge farming results
      farmingResults.remove('success');
      farmingResults.remove('message');
      farmingResults.remove('error');
      results.addAll(farmingResults);
      totalMigrated += (farmingResults['total'] as int?) ?? 0;

      // Migrate deals
      print('\n💰 Phase 2: Migrating Deal Data...');
      final dealsMigrated = await migrateDealsData();
      results['deals'] = dealsMigrated;
      totalMigrated += dealsMigrated;
      print('📊 Deals migrated: $dealsMigrated');

      // Migrate alternatives
      print('\n🌿 Phase 3: Migrating Alternatives Data...');
      final alternativesMigrated = await migrateAlternativesData();
      results['alternatives'] = alternativesMigrated;
      totalMigrated += alternativesMigrated;
      print('📊 Alternatives migrated: $alternativesMigrated');

      results['total'] = totalMigrated;
      results['success'] = true;
      results['message'] = 'Complete migration completed successfully';

      print('\n🎉 Complete Migration Successful!');
      print('📈 Total records migrated: $totalMigrated');
      print('🔥 Your app now uses Firebase for ALL data\n');
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['total'] = totalMigrated;
      results['message'] = 'Migration failed: $e';

      print('\n❌ Migration Failed: $e\n');
    }

    return results;
  }

  /// Main migration method - runs farming data migration
  Future<Map<String, dynamic>> migrateFarmingData() async {
    final results = <String, dynamic>{};
    int totalMigrated = 0;

    try {
      // Load the JSON data
      print('📖 Loading farming_data.json...');
      final String jsonString =
          await rootBundle.loadString('assets/json/farming_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final farmingData = FarmingData.fromJson(jsonData);
      print('✅ JSON data loaded successfully');

      // Migrate crops
      final cropsMigrated = await _migrateCrops(farmingData.crops);
      results['crops'] = cropsMigrated;
      totalMigrated += cropsMigrated;

      // Migrate objectives
      final objectivesMigrated =
          await _migrateObjectives(farmingData.objectives);
      results['objectives'] = objectivesMigrated;
      totalMigrated += objectivesMigrated;

      // Migrate products (farming products)
      final productsMigrated = await _migrateProducts(farmingData.products);
      results['products'] = productsMigrated;
      totalMigrated += productsMigrated;

      // Migrate recommendations
      final recommendationsMigrated =
          await _migrateRecommendations(farmingData.recommendations);
      results['recommendations'] = recommendationsMigrated;
      totalMigrated += recommendationsMigrated;

      results['total'] = totalMigrated;
      results['success'] = true;
    } catch (e) {
      results['success'] = false;
      results['error'] = e.toString();
      results['total'] = totalMigrated;
    }

    return results;
  }

  /// Migrate deals data
  Future<int> migrateDealsData() async {
    try {
      // Load deals JSON data
      print('📖 Loading sample_deals.json...');
      final String jsonString =
          await rootBundle.loadString('assets/json/sample_deals.json');
      final List<dynamic> dealsJson = json.decode(jsonString);

      print('✅ Deal data loaded successfully');
      return await _migrateDeals(
          dealsJson.map((deal) => Deal.fromJson(deal)).toList());
    } catch (e) {
      print('❌ Failed to load deals data: $e');
      return 0;
    }
  }

  /// Migrate alternatives data
  Future<int> migrateAlternativesData() async {
    try {
      // Load alternatives JSON data
      print('📖 Loading sample_alternatives.json...');
      final String jsonString =
          await rootBundle.loadString('assets/json/sample_alternatives.json');
      final List<dynamic> alternativesJson = json.decode(jsonString);

      print('✅ Alternatives data loaded successfully');
      return await _migrateAlternatives(
          alternativesJson.map((alt) => Alternative.fromJson(alt)).toList());
    } catch (e) {
      print('❌ Failed to load alternatives data: $e');
      return 0;
    }
  }

  /// Migrate crops to Firestore
  Future<int> _migrateCrops(List<Crop> crops) async {
    final cropRepository = CropRepository(_client);
    int migrated = 0;

    for (final crop in crops) {
      try {
        await cropRepository.createCrop(crop);
        migrated++;
        print('  ✅ Migrated crop: ${crop.name}');
      } catch (e) {
        print('  ❌ Failed to migrate crop ${crop.name}: $e');
      }
    }

    return migrated;
  }

  /// Migrate objectives to Firestore
  Future<int> _migrateObjectives(List<Objective> objectives) async {
    final objectiveRepository = ObjectiveRepository(_client);
    int migrated = 0;

    for (final objective in objectives) {
      try {
        await objectiveRepository.createObjective(objective);
        migrated++;
        print('  ✅ Migrated objective: ${objective.name}');
      } catch (e) {
        print('  ❌ Failed to migrate objective ${objective.name}: $e');
      }
    }

    return migrated;
  }

  /// Migrate products (farming products) to Firestore
  Future<int> _migrateProducts(List<FarmingProduct> products) async {
    final productRepository = ProductRepository(_client);
    int migrated = 0;

    for (final product in products) {
      try {
        await productRepository.createProduct(product);
        migrated++;
        print('  ✅ Migrated product: ${product.name}');
      } catch (e) {
        print('  ❌ Failed to migrate product ${product.name}: $e');
      }
    }

    return migrated;
  }

  /// Migrate recommendations to Firestore
  Future<int> _migrateRecommendations(
      List<Recommendation> recommendations) async {
    final recommendationRepository = RecommendationRepository(_client);
    int migrated = 0;

    for (final recommendation in recommendations) {
      try {
        await recommendationRepository.createRecommendation(recommendation);
        migrated++;
        print(
            '  ✅ Migrated recommendation: ${recommendation.dealUuid} (${recommendation.cropId} → ${recommendation.objectiveId})');
      } catch (e) {
        print(
            '  ❌ Failed to migrate recommendation ${recommendation.dealUuid}: $e');
      }
    }

    return migrated;
  }

  /// Migrate deals to Firestore
  Future<int> _migrateDeals(List<Deal> deals) async {
    final dealRepository = DealRepository(_client);
    int migrated = 0;

    for (final deal in deals) {
      try {
        await dealRepository.createDeal(deal);
        migrated++;
        print('  ✅ Migrated deal: ${deal.title}');
      } catch (e) {
        print('  ❌ Failed to migrate deal ${deal.title}: $e');
      }
    }

    return migrated;
  }

  /// Migrate alternatives to Firestore
  Future<int> _migrateAlternatives(List<Alternative> alternatives) async {
    final alternativeRepository = AlternativeRepository(_client);
    int migrated = 0;

    for (final alternative in alternatives) {
      try {
        await alternativeRepository.createAlternative(alternative);
        migrated++;
        print('  ✅ Migrated alternative: ${alternative.title}');
      } catch (e) {
        print('  ❌ Failed to migrate alternative ${alternative.title}: $e');
      }
    }

    return migrated;
  }

  /// Check if Firebase collections are empty (for migration status)
  Future<bool> collectionsAreEmpty() async {
    try {
      // Check if crops collection has any documents
      final cropsSnapshot = await FirestoreCollections.cropsRef.limit(1).get();
      if (cropsSnapshot.docs.isNotEmpty) return false;

      // Check if objectives collection has any documents
      final objectivesSnapshot =
          await FirestoreCollections.objectivesRef.limit(1).get();
      if (objectivesSnapshot.docs.isNotEmpty) return false;

      // Check if products collection has any documents
      final productsSnapshot =
          await FirestoreCollections.productsRef.limit(1).get();
      if (productsSnapshot.docs.isNotEmpty) return false;

      return true;
    } catch (e) {
      print('Error checking collections: $e');
      return true; // Assume empty if we can't check
    }
  }

  /// Clear all Firebase collections (dangerous - use only for testing)
  Future<void> clearAllCollections() async {
    print('⚠️  Clearing all collections - THIS IS IRREVERSIBLE!');

    // Clear crops
    final cropsSnapshot = await FirestoreCollections.cropsRef.get();
    for (final doc in cropsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Clear objectives
    final objectivesSnapshot = await FirestoreCollections.objectivesRef.get();
    for (final doc in objectivesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Clear products
    final productsSnapshot = await FirestoreCollections.productsRef.get();
    for (final doc in productsSnapshot.docs) {
      await doc.reference.delete();
    }

    // Clear recommendations
    final recommendationsSnapshot =
        await FirestoreCollections.recommendationsRef.get();
    for (final doc in recommendationsSnapshot.docs) {
      await doc.reference.delete();
    }

    print('✅ All collections cleared');
  }
}

/// Migration widget for easy integration into Flutter app
class MigrationWidget extends StatefulWidget {
  const MigrationWidget({Key? key}) : super(key: key);

  @override
  State<MigrationWidget> createState() => _MigrationWidgetState();
}

class _MigrationWidgetState extends State<MigrationWidget> {
  bool _isMigrating = false;
  String _migrationStatus = '';
  Map<String, dynamic>? _results;

  Future<void> _runMigration() async {
    setState(() {
      _isMigrating = true;
      _migrationStatus = 'Initializing migration...';
    });

    try {
      final migration = DataMigration(FirestoreClient());
      _results = await migration.migrateAllData();

      setState(() {
        _migrationStatus = _results?['message'] ?? 'Migration completed';
      });
    } catch (e) {
      setState(() {
        _migrationStatus = 'Migration failed: $e';
      });
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Migration'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Data Migration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will migrate your farming data from JSON files to Firebase Firestore.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (_results != null) ...[
              Text(
                'Migration Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Crops: ${_results?['crops'] ?? 0}'),
              Text('Objectives: ${_results?['objectives'] ?? 0}'),
              Text('Products: ${_results?['products'] ?? 0}'),
              Text('Recommendations: ${_results?['recommendations'] ?? 0}'),
              Text('Total: ${_results?['total'] ?? 0}'),
              const SizedBox(height: 24),
            ],
            Text(_migrationStatus),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isMigrating ? null : _runMigration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isMigrating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Run Migration',
                        style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Migration CLI function (can be called from main.dart for CLI usage)
// Example usage in main.dart:
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await FirebaseConfig.initialize();
//   final migration = DataMigration(FirestoreClient());
//   final results = await migration.migrateFarmingData();
//   print(results);
// }
