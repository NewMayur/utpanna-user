import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utpanna/models/alternative.dart';
import 'package:utpanna/models/product.dart';
import 'package:utpanna/screens/alternative_detail_screen.dart';
import 'package:utpanna/utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? product;
  List<Alternative> alternatives = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/products/${widget.productId}'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        Duration(seconds: Constants.timeoutDuration),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> productData = jsonDecode(response.body);
        setState(() {
          // Product.fromJson now handles alternatives parsing
          product = Product.fromJson(productData); 
          // Remove redundant alternatives parsing here
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load product details. Status code: ${response.statusCode}';
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
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: _isLoading
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
                        onPressed: fetchProductDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : product == null
                  ? const Center(child: Text('No product details available'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image (max 30% of screen)
                            Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product!.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, size: 200);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Product Details
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product!.title,
                                  style: const TextStyle(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Category: ${product!.broadCategory}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Price: ₹${product!.mrp}',
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Use actual data from product object
                                _buildDetailRow('Chemical Composition', product!.chemicalComposition ?? 'N/A'),
                                _buildDetailRow('Mode of Action', product!.modeOfAction ?? 'N/A'),
                                _buildDetailRow('Active Ingredient', product!.activeIngredient ?? 'N/A'),
                                _buildDetailRow('Usage Directions', product!.usageDirection ?? 'N/A'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Crops
                            const Text(
                              'Crops:',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: product!.crops
                                  .map((crop) => Chip(
                                        label: Text(crop),
                                        backgroundColor: Colors.green[100],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            // Alternatives
                            const Text(
                              'Alternatives:',
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Use alternatives from the product object
                            (product!.alternatives == null || product!.alternatives!.isEmpty)
                                ? const Text('No alternatives found')
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: product!.alternatives!.length,
                                    itemBuilder: (context, index) {
                                      // Assuming AlternativeProduct model from product.dart is compatible
                                      // with the expected Alternative model here.
                                      // If not, this part might need further adjustment based on alternative.dart content.
                                      final alternative = product!.alternatives![index]; 
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 4),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AlternativeDetailScreen(
                                                  alternativeId: alternative.id,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Row(
                                              children: [
                                                // Image (2/5 width)
                                                Expanded(
                                                  flex: 2,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: Image.network(
                                                      alternative.imageUrl,
                                                      height: 150,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Details (3/5 width)
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        alternative.title,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Price: ₹${alternative.price}',
                                                        style: TextStyle(
                                                          color: Colors.green[800],
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'Savings: ₹${alternative.savings}',
                                                        style: const TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
