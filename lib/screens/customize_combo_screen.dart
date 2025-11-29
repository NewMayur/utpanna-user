import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/combo_provider.dart';
import '../models/farming_models.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;

class CustomizeComboScreen extends StatefulWidget {
  const CustomizeComboScreen({Key? key}) : super(key: key);

  @override
  State<CustomizeComboScreen> createState() => _CustomizeComboScreenState();
}

class _CustomizeComboScreenState extends State<CustomizeComboScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with recommended products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider =
            Provider.of<ComboBuilderProvider>(context, listen: false);
        provider
            .resetToRecommended(); // Start with recommended products selected
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
          title: const Text('स्वतःचा कॉम्बो बनवा'),
        ),
        body: const Center(
          child: Text('No recommendation available'),
        ),
      );
    }

    final groupedProducts = provider.getProductsGroupedByCategory();

    return Scaffold(
      appBar: AppBar(
        title: const Text('स्वतःचा कॉम्बो बनवा'),
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.orange.shade100,
            child: const Text(
              'स्वतःचा कॉम्बो फक्त खर्च मोजणीसाठी आहे. सध्या ठरलेला कॉम्बोच फक्त खरेदी करता येणार.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.comboTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'तुमच्या जमिनीनुसार प्रमाण ठेवा',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // All products by category
                  ..._buildProductsByCategory(provider),
                ],
              ),
            ),
          ),

          // Bottom summary and actions
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'एकूण अंदाजे खर्च:',
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
                        label: const Text('प्रति एकर'),
                        selected: provider.isByAcre,
                        onSelected: (selected) {
                          if (selected) provider.togglePricingMode();
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('प्रति पंप'),
                        selected: !provider.isByAcre,
                        onSelected: (selected) {
                          if (selected) provider.togglePricingMode();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _resetToRecommended(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('रीसेट करा'),
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
                                'Join Group',
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

  void _resetToRecommended(BuildContext context) {
    final provider = Provider.of<ComboBuilderProvider>(context, listen: false);
    provider.resetToRecommended();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to recommended quantities'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  List<Widget> _buildProductsByCategory(ComboBuilderProvider provider) {
    // Group products by category
    final groupedProducts = <String, List<FarmingProduct>>{};

    for (final product in provider.farmingData!.products) {
      if (!groupedProducts.containsKey(product.category)) {
        groupedProducts[product.category] = [];
      }
      groupedProducts[product.category]!.add(product);
    }

    // Build the list of category sections
    final List<Widget> categorySections = [];

    for (final entry in groupedProducts.entries) {
      final category = entry.key;
      final products = entry.value;

      final categorySection = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...products.map((product) {
            final isIncluded = provider.isProductInCustom(product.id);
            final quantityText =
                provider.customQuantities[product.id]?.toString() ?? '1.0';
            final quantity = double.tryParse(quantityText) ?? 1.0;
            final itemPrice = isIncluded ? quantity * product.price : 0.0;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isIncluded ? Colors.white : Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isIncluded
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left section: Product name with unit and base price
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.unit} • ₹${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Middle section: Required quantity input
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Required Quantity',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 80,
                                  height: 36,
                                  child: TextFormField(
                                    initialValue: quantityText,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
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
                              ],
                            ),
                          ),

                          // Right section: Remove button and Reflecting price
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Remove button
                              TextButton.icon(
                                onPressed: () => provider
                                    .removeProductFromCustom(product.id),
                                icon: Icon(Icons.remove_circle,
                                    size: 16, color: Colors.red[400]),
                                label: const Text('Remove'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red[400],
                                  textStyle: const TextStyle(fontSize: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Price
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '₹${itemPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF44aa00),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: Product name, unit/price, and add button
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.unit} • ₹${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: Add button
                          TextButton.icon(
                            onPressed: () =>
                                provider.addProductToCustom(product.id),
                            icon: Icon(Icons.add_circle,
                                size: 20, color: const Color(0xFF44aa00)),
                            label: const Text('Add'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF44aa00),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],
      );

      categorySections.add(categorySection);
    }

    return categorySections;
  }

  Future<void> _joinDeal(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Standard Deal?'),
        content: const Text(
          'Group deals are only available for the recommended combo. '
          'Do you want to discard changes and join the standard deal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join Standard Deal'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Reset to recommended and navigate back to combo deal screen
    final provider = Provider.of<ComboBuilderProvider>(context, listen: false);
    provider.resetToRecommended();

    Navigator.pop(context); // Go back to combo deal screen
    // The combo deal screen will handle the actual joining
  }
}
