import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utpanna/models/alternative.dart';
import 'package:utpanna/utils/constants.dart';

class AlternativeDetailScreen extends StatefulWidget {
  final String alternativeId;

  const AlternativeDetailScreen({Key? key, required this.alternativeId}) : super(key: key);

  @override
  State<AlternativeDetailScreen> createState() => _AlternativeDetailScreenState();
}

class _AlternativeDetailScreenState extends State<AlternativeDetailScreen> {
  Alternative? alternative;
  bool _isLoading = true;
  String _errorMessage = '';

  // State for PageView
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchAlternativeDetails();
  }

  Future<void> fetchAlternativeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/alternatives/${widget.alternativeId}'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        Duration(seconds: Constants.timeoutDuration),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> alternativeData = jsonDecode(response.body);
        setState(() {
          alternative = Alternative.fromJson(alternativeData);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load alternative details. Status code: ${response.statusCode}';
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
        title: const Text('Alternative Details'),
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
                        onPressed: fetchAlternativeDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : alternative == null
                  ? const Center(child: Text('No alternative details available'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alternative!.title,
                              style: const TextStyle(
                                fontSize: 24, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Alternative Image PageView
                            if (alternative!.imageUrls.isNotEmpty)
                              Container(
                                height: MediaQuery.of(context).size.height * 0.35, // Match ProductDetailScreen height
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    PageView.builder(
                                      controller: _pageController,
                                      itemCount: alternative!.imageUrls.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _currentImageIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              alternative!.imageUrls[index], // Use list item
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return const Center(child: CircularProgressIndicator());
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Center(child: Icon(Icons.error, size: 50, color: Colors.grey));
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(alternative!.imageUrls.length, (index) {
                                          return Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentImageIndex == index
                                                  ? Theme.of(context).primaryColor // Use theme color
                                                  : Colors.grey.withOpacity(0.6),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else // Placeholder if no images
                              Container(
                                height: MediaQuery.of(context).size.height * 0.3,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                              ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Price', '₹${alternative!.price}'),
                            _buildDetailRow('Savings', '₹${alternative!.savings}'),
                            _buildDetailRow('Chemical Composition', alternative!.chemicalComposition),
                            _buildDetailRow('Mode of Action', alternative!.modeOfAction),
                            _buildDetailRow('Active Ingredient', alternative!.activeIngredient),
                            _buildDetailRow('Usage Direction', alternative!.usageDirection),
                            const SizedBox(height: 16),
                            const Text(
                              'Used For:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: alternative!.usedFor
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
