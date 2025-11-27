import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utpanna/models/alternative.dart';
import 'package:utpanna/utils/savings_calculator.dart';
import 'package:utpanna/providers/alternative_provider.dart';

class AlternativeDetailScreen extends StatefulWidget {
  final String alternativeId;
  final double mrp;
  final String broadCategory;

  const AlternativeDetailScreen({
    Key? key,
    required this.alternativeId,
    required this.mrp,
    required this.broadCategory,
  }) : super(key: key);

  @override
  State<AlternativeDetailScreen> createState() =>
      _AlternativeDetailScreenState();
}

class _AlternativeDetailScreenState extends State<AlternativeDetailScreen> {
  // State for PageView
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AlternativeProvider>(
      builder: (context, alternativeProvider, child) {
        final alternative =
            alternativeProvider.getAlternativeByIdLocally(widget.alternativeId);
        final isLoading = alternativeProvider.isLoading;
        final errorMessage = alternativeProvider.errorMessage;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Alternative Details'),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $errorMessage',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                alternativeProvider.loadAlternatives(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : alternative == null
                      ? const Center(
                          child: Text('Alternative not found'),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alternative.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Alternative Image PageView
                                if (alternative.imageUrls.isNotEmpty)
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        PageView.builder(
                                          controller: _pageController,
                                          itemCount:
                                              alternative.imageUrls.length,
                                          onPageChanged: (index) {
                                            setState(() {
                                              _currentImageIndex = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  alternative.imageUrls[index],
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Center(
                                                        child: Icon(Icons.error,
                                                            size: 50,
                                                            color:
                                                                Colors.grey));
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Page Indicators
                                        Positioned(
                                          bottom: 10.0,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                                alternative.imageUrls.length,
                                                (index) {
                                              return Container(
                                                width: 8.0,
                                                height: 8.0,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 2.0),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _currentImageIndex ==
                                                          index
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.grey
                                                          .withOpacity(0.6),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  // Placeholder if no images
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                        child: Icon(Icons.image_not_supported,
                                            size: 50, color: Colors.grey)),
                                  ),
                                const SizedBox(height: 16),
                                _buildDetailRow('Price',
                                    '₹${alternative.price.toStringAsFixed(2)}'),
                                _buildDetailRow('Savings',
                                    '₹${alternative.savings.toStringAsFixed(2)}'),
                                _buildDetailRow('Per-Acre Savings',
                                    '₹${calculatePerAcreSavings(widget.mrp, alternative.price, getDefaultUsagePerAcre(widget.broadCategory)).toStringAsFixed(0)}'),
                                _buildDetailRow(
                                    'Views', '${alternative.viewCount}'),
                                _buildDetailRow('Chemical Composition',
                                    alternative.chemicalComposition),
                                _buildDetailRow(
                                    'Mode of Action', alternative.modeOfAction),
                                _buildDetailRow('Active Ingredient',
                                    alternative.activeIngredient),
                                _buildDetailRow('Usage Direction',
                                    alternative.usageDirection),
                                const SizedBox(height: 16),
                                const Text(
                                  'Used For:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: alternative.usedFor
                                      .map((use) => Chip(
                                            label: Text(use),
                                            backgroundColor: Colors.green[100],
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
        );
      },
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
