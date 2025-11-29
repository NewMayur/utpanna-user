import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:utpanna/models/product.dart';
import 'package:utpanna/models/deal.dart';
import 'package:utpanna/providers/combo_provider.dart';
import 'package:utpanna/screens/deals_screen.dart';
import 'package:utpanna/screens/objective_selection_screen.dart';
import 'package:utpanna/screens/deal_detail_screen.dart';
import 'package:utpanna/utils/constants.dart';
import 'package:utpanna/services/auth_service.dart';
import 'package:utpanna/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Deal> deals = [];
  bool dealsLoading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    setState(() {
      dealsLoading = true;
    });
    try {
      String? idToken = await _authService.getIdToken();
      if (idToken != null) {
        final response = await http.get(
          Uri.parse('${Constants.apiUrl}/deals'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> dealsJson = json.decode(response.body);
          setState(() {
            deals = dealsJson
                .map((json) => Deal.fromJson(json))
                .where((d) => d.status == 'open')
                .toList();
            dealsLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        dealsLoading = false;
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
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'group_deals',
                child: Text('ग्रुप खरेदी'),
              ),
            ],
          ),
        ],
      ),
      body: CropSelectionBody(deals: deals, dealsLoading: dealsLoading),
    );
  }
}

class CropSelectionBody extends StatelessWidget {
  final List<Deal> deals;
  final bool dealsLoading;
  const CropSelectionBody(
      {Key? key, required this.deals, required this.dealsLoading})
      : super(key: key);

  double _getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 380) {
      // Small screens - make cards wider to use available space
      return screenWidth - 32; // Account for minimal padding
    } else {
      // Normal screens - use current width
      return 330; // Slightly reduced from previous
    }
  }

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
            if (dealsLoading) ...[
              const Text(
                'पिके',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => const ShimmerDealCard(),
                ),
              ),
              const SizedBox(height: 10),
            ] else if (deals.isNotEmpty) ...[
              const Text(
                'ग्रुप खरेदी',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: deals.length,
                  itemBuilder: (context, index) {
                    final deal = deals[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DealDetailScreen(deal: deal),
                          ),
                        );
                      },
                      child: Container(
                        width: _getCardWidth(context),
                        margin: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            Card(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 180,
                                    child: Center(
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 2,
                                          mainAxisSpacing: 2,
                                        ),
                                        itemCount: 4,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: index == 3
                                                  ? Colors.grey[200]
                                                  : null,
                                            ),
                                            child: index < 3
                                                ? _buildDealImageForGrid(
                                                    deal, index)
                                                : const SizedBox.shrink(),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            deal.title,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            deal.description,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '₹${deal.deal_price.toStringAsFixed(0)} / प्रति एकर',
                                                  style: const TextStyle(
                                                      color: Color(0xFF44aa00),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  '${deal.spotsAvailable} जागा बाकी',
                                                  style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Deal status badge absolutely positioned at top left corner of card
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                ),
                                child: const Text(
                                  'Open',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            const Text(
              'पिके',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
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
                      margin: EdgeInsets.zero,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage(crop.imageAsset.isNotEmpty
                                ? crop.imageAsset
                                : 'assets/crops/cotton.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            crop.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
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

  Widget _buildDealImage(Deal deal, int index) {
    return Container(
      height: 60,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          deal.images != null && deal.images!.length > index
              ? deal.images![index]
              : 'https://placehold.co/90x70',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDealImageForGrid(Deal deal, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        deal.images != null && deal.images!.length > index
            ? deal.images![index]
            : 'https://placehold.co/90x70',
        fit: BoxFit.cover,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'starting soon':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class ShimmerDealCard extends StatelessWidget {
  const ShimmerDealCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 10),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          child: Row(
            children: [
              Container(
                width: 90,
                height: 150,
                color: Colors.white,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 16, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(height: 12, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 60, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 24, width: 80, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
