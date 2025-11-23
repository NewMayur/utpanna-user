import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/farming_models.dart';
import '../providers/combo_provider.dart';
import '../screens/customize_combo_screen.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/product_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ComboRecommendationScreen extends StatefulWidget {
  const ComboRecommendationScreen({Key? key}) : super(key: key);

  @override
  State<ComboRecommendationScreen> createState() =>
      _ComboRecommendationScreenState();
}

class _ComboRecommendationScreenState extends State<ComboRecommendationScreen> {
  final AuthService _authService = AuthService();
  final Color accentColor = const Color(0xFF44aa00);
  bool _comboAccordionExpanded = false; // Add this for combo accordion state

  @override
  void initState() {
    super.initState();
    // Initialize with recommended products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<ComboBuilderProvider>(context, listen: false);
        // Initialize the included products and quantities with recommended values
        provider.resetToRecommended();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComboBuilderProvider>(context);
    final recommendation = provider.currentRecommendation;

    if (recommendation == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Recommendations'),
        ),
        body: const Center(
          child: Text('No recommendation available'),
        ),
      );
    }

    final selectedCrop = provider.selectedCrop!;
    final selectedObjective = provider.selectedObjective!;
    final allProducts = provider.farmingData!.products;
    final groupedProducts = <String, List<dynamic>>{};

    // Group all products by category
    for (final product in allProducts) {
      final category = product.category;
      if (!groupedProducts.containsKey(category)) {
        groupedProducts[category] = [];
      }
      groupedProducts[category]!.add(product);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedCrop.name} → ${selectedObjective.name}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category product accordions
                  ..._buildCategoryProductAccordions(provider),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Combo section at bottom - Accordion Style
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Combo Header - Always Visible - Clean Structure
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎯 कॉम्बो',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.comboTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Expand/collapse icon on the right
                    IconButton(
                      onPressed: () => setState(() {
                        _comboAccordionExpanded = !_comboAccordionExpanded;
                      }),
                      icon: Icon(
                        _comboAccordionExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 24,
                        color: accentColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Always visible: Price and Toggle
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Pricing toggle - Always visible
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

                // Collapsible Content
                if (_comboAccordionExpanded) ...[
                  const SizedBox(height: 16),

                  // Image collage of combo products
                  _buildComboImageCollage(provider, recommendation),

                  const SizedBox(height: 16),

                  // Combo items with quantity inputs
                  const Text(
                    'Adjust Quantities (varies by land size):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...recommendation.items.map((item) {
                    final product = provider.getProductById(item.productId);
                    if (product == null) return const SizedBox.shrink();

                    final quantityText =
                        provider.customQuantities[product.id]?.toString() ??
                            item.qtyAcre.toString();
                    final quantity =
                        double.tryParse(quantityText) ?? item.qtyAcre;
                    final itemTotal = quantity * product.price;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${itemTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF44aa00),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Quantity: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: TextFormField(
                                    initialValue: quantityText,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        borderSide: const BorderSide(
                                            color: Color(0xFF44aa00)),
                                      ),
                                      hintText: '0.0',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (value) {
                                      final newQuantity =
                                          double.tryParse(value) ?? 0.0;
                                      if (newQuantity >= 0) {
                                        provider.updateCustomQuantity(
                                            product.id, newQuantity);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                product.unit,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
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
                          child: Text(
                            'Customize Combo',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showParticipateDialog(context, recommendation),
                          icon: const Icon(Icons.group_add),
                          label: const Text('Join Combo Deal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipateDialog(BuildContext context, dynamic recommendation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join the Combo Deal'),
          content: const Text(
              "Payment will be processed only if the deal is confirmed. You will be notified once the deal reaches the required number of participants. Do you want to join this combo deal?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child:
                  const Text('Confirm', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showUserDetailsDialog(context, recommendation);
              },
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context, dynamic recommendation) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Your Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF44aa00)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF44aa00)),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              onPressed: () async {
                String? idToken = await _authService.getIdToken();
                if (idToken == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Authentication error')),
                  );
                  return;
                }

                bool detailsUpdated = await _authService.updateUserDetails(
                  nameController.text,
                  addressController.text,
                  idToken,
                );

                if (detailsUpdated) {
                  try {
                    bool participated = await _authService.participateInDeal(
                        recommendation.dealUuid, idToken);
                    Navigator.of(context).pop();
                    if (participated) {
                      _showParticipationConfirmation(
                          context, 'Successfully joined the combo deal!');
                    }
                  } catch (e) {
                    String errorMessage = e.toString();
                    if (errorMessage.contains('Already participated')) {
                      _showParticipationConfirmation(
                          context, 'You have already joined this combo deal');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to join deal: $errorMessage')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Failed to update user details')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildComboImageCollage(
      ComboBuilderProvider provider, Recommendation recommendation) {
    final List<Widget> images = [];

    for (final item in recommendation.items) {
      final product = provider.getProductById(item.productId);
      if (product != null) {
        images.add(
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              image: DecorationImage(
                image: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? NetworkImage(product.imageUrl!)
                    : const NetworkImage(
                        'https://dujjhct8zer0r.cloudfront.net/media/prod_image/thumb/thumb222255_19318456721733210100.webp'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }
    }

    // If we have images, create a collage
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Combo Products:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryProductAccordions(ComboBuilderProvider provider) {
    // Group products by category
    final groupedProducts = <String, List<dynamic>>{};

    for (final product in provider.farmingData!.products) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    final List<Widget> categoryAccordions = [];

    for (final entry in groupedProducts.entries) {
      final category = entry.key;
      final products = entry.value;

      categoryAccordions.add(
        CategoryAccordion(
          category: category,
          products: products,
        ),
      );
    }

    return categoryAccordions;
  }

  void _showParticipationConfirmation(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: accentColor,
      ),
    );
  }
}

class CategoryAccordion extends StatefulWidget {
  final String category;
  final List<dynamic> products;

  const CategoryAccordion({
    Key? key,
    required this.category,
    required this.products,
  }) : super(key: key);

  @override
  State<CategoryAccordion> createState() => _CategoryAccordionState();
}

class _CategoryAccordionState extends State<CategoryAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          // Header
          ListTile(
            title: Text(
              widget.category,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),

          // Expandable content with product cards
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 products per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75, // Taller cards for vertical layout
                ),
                itemCount: widget.products.length,
                itemBuilder: (context, index) {
                  final product = widget.products[index];
                  return VerticalProductCard(
                    product: product,
                    onTap: () {
                      // Navigate to product detail screen or show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} tapped'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
