import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deal.dart';
import './deal_detail_screen.dart';
import '../services/auth_service.dart';
import '../providers/deal_provider.dart';
import 'phone_auth_screen.dart';

class DealsScreen extends StatefulWidget {
  const DealsScreen({Key? key}) : super(key: key);

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends State<DealsScreen> {
  final AuthService _authService = AuthService();
  final Color accentColor;
  final ScrollController _scrollController;

  _DealsScreenState()
      : accentColor = const Color(0xFF44aa00),
        _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Consumer<DealProvider>(
      builder: (context, dealProvider, child) {
        final deals = dealProvider.deals;
        final isLoading = dealProvider.isLoading;

        return Scaffold(
          appBar: AppBar(
            title: Image.asset(
              'assets/icons/logo-full.png',
              height: 32,
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.exit_to_app, color: accentColor),
                onPressed: () async {
                  await _authService.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
                  );
                },
              ),
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: accentColor))
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: AspectRatio(
                        aspectRatio: 3.88, // 970/250 = 3.88
                        child: Image.asset(
                          'assets/images/banner.jpg',
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final deal = deals[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DealDetailScreen(deal: deal),
                                  ),
                                );
                              },
                              child: Card(
                                margin: EdgeInsets.only(bottom: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        deal.images?.isNotEmpty == true
                                            ? deal.images![0]
                                            : 'https://placehold.co/300x400',
                                        width: 120,
                                        height: 160,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deal.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              deal.description,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  'MRP: ₹${deal.mrp.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  '₹${deal.deal_price.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: accentColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Chip(
                                                  label: Text(
                                                    deal.status,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      _getStatusColor(
                                                          deal.status),
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                Text(
                                                  '${deal.spotsAvailable} spots left',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
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
                            );
                          },
                          childCount: deals.length,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Need any help?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Implement call functionality
                              },
                              icon: Icon(Icons.phone, color: Colors.white),
                              label: Text('Call us now',
                                  style: TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
