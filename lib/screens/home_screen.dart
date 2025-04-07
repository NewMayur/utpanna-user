import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utpanna/models/product.dart';
import 'package:utpanna/screens/deals_screen.dart';
import 'package:utpanna/utils/constants.dart';
import 'package:utpanna/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  bool _isLoading = true;
  String _errorMessage = '';

  Future<void> fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(Constants.productsApi),
        headers: {'Accept': 'application/json'},
      ).timeout(
        Duration(seconds: Constants.timeoutDuration),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> productList = jsonDecode(response.body);
        setState(() {
          products = productList.map((e) => Product.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load products. Status code: ${response.statusCode}';
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Image.asset(
          'assets/icons/logo-full.png',
          height: 38.4, // Reduced height by 20%
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DealsScreen()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF44aa00),
            ),
            child: const Text(
              'Group Deals',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
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
                          onPressed: fetchProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Image.asset(
                        'assets/images/banner.jpg',
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Expanded(
                        child: products.isEmpty
                            ? const Center(child: Text('No products found'))
                            : ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  return ProductCard(product: products[index]);
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
