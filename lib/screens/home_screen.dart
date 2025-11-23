import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:utpanna/models/product.dart';
import 'package:utpanna/providers/combo_provider.dart';
import 'package:utpanna/screens/deals_screen.dart';
import 'package:utpanna/screens/objective_selection_screen.dart';
import 'package:utpanna/utils/constants.dart';
import 'package:utpanna/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(Constants.productsApi),
        headers: {'Accept': 'application/json'},
      ).timeout(
        Duration(seconds: Constants.timeoutDuration),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productList = jsonDecode(response.body);
        setState(() {
          products = productList.map((e) => Product.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load products. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Image.asset(
          'assets/icons/logo-full.png',
          height: 38.4, // Reduced height by 20%
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              switch (value) {
                case 'group_deals':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DealsScreen()),
                  );
                  break;
                case 'products':
                  _showProductsScreen(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'group_deals',
                child: Text('Group Deals'),
              ),
              const PopupMenuItem<String>(
                value: 'products',
                child: Text('Products'),
              ),
            ],
          ),
        ],
      ),
      body: const CropSelectionBody(),
    );
  }

  void _showProductsScreen(BuildContext context) {
    // Navigate to the original product list screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Products')),
          body: Column(
            children: [
              Image.asset(
                'assets/images/banner.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: fetchProducts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : products.isEmpty
                            ? const Center(child: Text('No products found'))
                            : ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(product: products[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CropSelectionBody extends StatelessWidget {
  const CropSelectionBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComboBuilderProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          provider.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your crop to get personalized product recommendations',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: provider.farmingData!.crops.length,
                itemBuilder: (context, index) {
                  final crop = provider.farmingData!.crops[index];
                  return GestureDetector(
                    onTap: () {
                      provider.selectCrop(crop);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ObjectiveSelectionScreen(),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Placeholder for crop image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.grass,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            crop.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
