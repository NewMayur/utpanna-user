import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/combo_provider.dart';
import '../screens/customize_combo_screen.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComboDealScreen extends StatefulWidget {
  const ComboDealScreen({Key? key}) : super(key: key);

  @override
  State<ComboDealScreen> createState() => _ComboDealScreenState();
}

class _ComboDealScreenState extends State<ComboDealScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComboBuilderProvider>(context);
    final recommendation = provider.currentRecommendation;
    final groupedProducts = provider.getProductsGroupedByCategory();

    if (recommendation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Deal'),
        ),
        body: const Center(
          child: Text('No recommendation available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recommendation.comboTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Products grouped by category
                  ...groupedProducts.entries.map((entry) {
                    final category = entry.key;
                    final products = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...products.map((product) {
                          final item = recommendation.items.firstWhere(
                            (i) => i.productId == product.id,
                          );
                          final qty =
                              provider.isByAcre ? item.qtyAcre : item.qtyPump;
                          final itemTotal = qty * product.price;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${qty.toStringAsFixed(1)} ${product.unit}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${itemTotal.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (product.activeDealUuid != null) ...[
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Navigate to individual product deal
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Individual product deals coming soon!'),
                                          ),
                                        );
                                      },
                                      child: const Text('View Deal'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom summary card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pricing toggle
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChoiceChip(
                        label: const Text('Per Acre'),
                        selected: provider.isByAcre,
                        onSelected: (selected) {
                          if (selected) provider.togglePricingMode();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Per Pump'),
                        selected: !provider.isByAcre,
                        onSelected: (selected) {
                          if (selected) provider.togglePricingMode();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Estimated Cost:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${provider.calculateTotal().toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF44aa00),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.initializeCustomQuantities();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CustomizeComboScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Customize Combo'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _joinDeal(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF44aa00),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Join Deal',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinDeal(BuildContext context) async {
    final provider = Provider.of<ComboBuilderProvider>(context, listen: false);
    final recommendation = provider.currentRecommendation;

    if (recommendation == null) return;

    // Get user details
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Deal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You are joining the "${recommendation.comboTitle}" deal.'),
            const SizedBox(height: 16),
            Text(
              'Total Estimated Cost: ₹${provider.calculateTotal().toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm & Join'),
          ),
        ],
      ),
    );

    if (confirmed != true ||
        nameController.text.isEmpty ||
        addressController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final idToken = await _authService.getIdToken();
      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse(
            '${Constants.apiUrl}/deals/${recommendation.dealUuid}/participate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'name': nameController.text,
          'address': addressController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Participation confirmed! We will notify you when the deal closes.'),
            backgroundColor: Colors.green,
          ),
        );
        // TODO: Navigate to home or deals list
      } else {
        throw Exception('Failed to join deal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining deal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
