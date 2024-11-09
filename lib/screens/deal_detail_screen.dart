import 'package:flutter/material.dart';
import '../models/deal.dart';
import '../services/auth_service.dart';
import '../models/user_details.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;

  DealDetailScreen({Key? key, required this.deal}) : super(key: key);

  @override
  _DealDetailScreenState createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  final AuthService _authService = AuthService();
  final Color accentColor = Color(0xFF44aa00);
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                floating: true,
                pinned: false,
              ),
              SliverToBoxAdapter(
                child: Container(
                  height: 300,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: widget.deal.images?.length ?? 1,
                        itemBuilder: (context, index) {
                          return Image.network(
                            widget.deal.images?.isNotEmpty == true
                                ? widget.deal.images![index]
                                : 'https://placehold.co/400x300',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.deal.images?.length ?? 1,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? accentColor
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      widget.deal.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'MRP: ₹${widget.deal.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '₹${(widget.deal.price * 0.8).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Minimum',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.deal.min_participants}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          Column(
                            children: [
                              Text(
                                'Current',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${widget.deal.current_participants}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      widget.deal.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            label: Text('Call us now', style: TextStyle(color: Colors.white)),
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
                    SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () => _showParticipateDialog(context),
              child: Text(
                'Participate in Deal',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Participate in Deal'),
          content: Text(
            "Payment will be processed only if the deal is confirmed. You will be notified once the deal reaches the required number of participants. Do you want to participate in this deal?"
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Confirm', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showUserDetailsDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailsDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: accentColor),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Save', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
              ),
              onPressed: () async {
                String? idToken = await _authService.getIdToken();
                if (idToken == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Authentication error')),
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
                    bool participated = await _authService.participateInDeal(widget.deal.id, idToken);
                    Navigator.of(context).pop();
                    if (participated) {
                      _showParticipationConfirmation(context, 'Participation successful!');
                    }
                  } catch (e) {
                    String errorMessage = e.toString();
                    if (errorMessage.contains('Already participated')) {
                      _showParticipationConfirmation(context, 'You have already participated in this deal');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to participate in deal: $errorMessage')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update user details')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showParticipationConfirmation(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: accentColor,
      ),
    );
  }
}
