import 'package:flutter/material.dart';
import '../models/deal.dart';
import '../services/auth_service.dart';
import '../models/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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
  Deal? _currentDeal;
  bool _isLoadingDeal = false;

  @override
  void initState() {
    super.initState();
    _currentDeal = widget.deal;
    _fetchDealDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh deal data when returning to this screen
    if (!_isLoadingDeal) {
      _fetchDealDetails();
    }
  }

  Future<void> _fetchDealDetails() async {
    setState(() {
      _isLoadingDeal = true;
    });

    try {
      String? idToken = await _authService.getIdToken();
      if (idToken == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/deals/${widget.deal.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final dealJson = json.decode(response.body);
        setState(() {
          _currentDeal = Deal.fromJson(dealJson);
          _isLoadingDeal = false;
        });
      } else {
        throw Exception('Failed to load deal details');
      }
    } catch (e) {
      setState(() {
        _isLoadingDeal = false;
      });
      // Keep existing deal data if fetch fails
      print('Error fetching deal details: $e');
    }
  }

  String _getDealMessage() {
    if (_currentDeal == null) return "";
    switch (_currentDeal!.status.toLowerCase()) {
      case 'closed':
        return "Group was completed and the deal is closed. We'll notify you once the deal reopens.";
      case 'open':
        return ""; // No message when deal is open
      default:
        return "We'll notify you once the deal starts.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDeal = _currentDeal ?? widget.deal;
    final dealMessage = _getDealMessage();
    final showJoinButton = currentDeal.status.toLowerCase() == 'open';
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = ((screenWidth * 4) / 3) - 20; // 3:4 aspect ratio - 20px

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
                  height: imageHeight,
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
                          return AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Image.network(
                              widget.deal.images?.isNotEmpty == true
                                  ? widget.deal.images![index]
                                  : 'https://placehold.co/300x400',
                              fit: BoxFit.cover,
                            ),
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
                          'MRP: ₹${widget.deal.mrp.toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '₹${widget.deal.deal_price.toStringAsFixed(2)} / प्रति एकर',
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
                                'Group Size',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${currentDeal.min_participants}',
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
                                'Spots Available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${currentDeal.spotsAvailable}',
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
                    if (dealMessage.isNotEmpty) ...[
                      SizedBox(height: 24),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dealMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
                            'काही प्रश्न आहेत ? ',
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
                    SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
          // WhatsApp Share Button - Floating at top
          Positioned(
            top: MediaQuery.of(context).padding.top +
                56, // Below status bar and app bar
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey[300]!, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _shareDealOnWhatsApp(context, currentDeal),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/whatsapp.png',
                      width: 16,
                      height: 16,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ग्रुप पूर्ण करण्यासाठी शेअर करा!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showJoinButton)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: () => _showParticipateDialog(context),
                child: Text(
                  'Join the Group',
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
          title: Text('Join the Group'),
          content: Text(
              "ग्रुप मध्ये लागणारे लोक भरले कि तुमचा ऑर्डर बुक होईल व मॅसेज येईल.  तर लवकर ग्रुपमध्ये जॉईन व्हा !"),
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
                    bool participated = await _authService.participateInDeal(
                        widget.deal.id, idToken);
                    Navigator.of(context).pop();
                    if (participated) {
                      _showParticipationConfirmation(
                          context, 'Successfully joined the deal!');
                    }
                  } catch (e) {
                    String errorMessage = e.toString();
                    if (errorMessage.contains('Already participated')) {
                      _showParticipationConfirmation(
                          context, 'You have already joined this deal');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Failed to Join Group: $errorMessage')),
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

  Future<void> _shareDealOnWhatsApp(BuildContext context, Deal deal) async {
    final String message = """
🌾 ${deal.title}

💰 ग्रुप किंमत: ₹${deal.deal_price.toStringAsFixed(0)} / प्रति एकर
💸 MRP: ₹${deal.mrp.toStringAsFixed(0)}

🪑 जागा बाकी : ${deal.spotsAvailable}

🔗 ग्रुप पूर्ण व्हायच्या आधी जॉईन करा आणि आपला ऑर्डर बुक करा !

👉 *जॉईन करा:* https://utpanna.live
    """;

    try {
      final String whatsappUrl =
          "https://wa.me/?text=${Uri.encodeComponent(message)}";

      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for web: show message to user
        await _showWebShareDialog(context, message);
      }
    } catch (e) {
      // Handle web specifically
      if (e.toString().contains('MissingPluginException') ||
          e.toString().contains('no implementation found')) {
        await _showWebShareDialog(context, message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open WhatsApp: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showWebShareDialog(BuildContext context, String message) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.asset(
                'assets/icons/whatsapp.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              const Text('Share Deal'),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: SelectableText(
                message.trim(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy Message'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Message copied to clipboard! Open WhatsApp and paste to share.'),
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
