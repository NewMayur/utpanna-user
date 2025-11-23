import 'package:flutter/material.dart';
import '../models/farming_models.dart';

// Existing ProductCard for API Product model - unchanged
class ProductCard extends StatelessWidget {
  final dynamic product; // Can be Product or FarmingProduct
  final VoidCallback? onTap;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Handle API Product model (from product.dart)
    if (product is! FarmingProduct) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 3,
          margin: const EdgeInsets.all(8),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.inventory, size: 50, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name ?? 'Product',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Handle FarmingProduct model - new vertical card design
    final farmingProduct = product as FarmingProduct;

    return VerticalProductCard(
      product: farmingProduct,
      onTap: onTap,
    );
  }
}

// New VerticalProductCard for farming products
class VerticalProductCard extends StatelessWidget {
  final FarmingProduct product;
  final VoidCallback? onTap;

  const VerticalProductCard({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.all(8),
        child: IntrinsicHeight(
          // Allow height to fit content
          child: Container(
            width: 190, // Increased by 10px (5px larger images)
            constraints:
                const BoxConstraints(maxWidth: 210), // Max width constraint
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Fit to content height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with Discount Badge - Flexible height
                Flexible(
                  child: Stack(
                    children: [
                      // Product Image
                      AspectRatio(
                        // Use aspect ratio for consistent scaling
                        aspectRatio: 1.0, // Square aspect ratio
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: product.imageUrl != null &&
                                      product.imageUrl!.isNotEmpty
                                  ? NetworkImage(product.imageUrl!)
                                  : const NetworkImage(
                                      'https://dujjhct8zer0r.cloudfront.net/media/prod_image/thumb/thumb222255_19318456721733210100.webp'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Discount Badge
                      if (product.discountPercent > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1), // Smaller padding
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${product.discountPercent.toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9, // Smaller font
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Product Name - Flexible with wrapping
                Flexible(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 13, // Slightly smaller font
                            fontWeight: FontWeight.w600,
                            height: 1.2, // Line height for better readability
                          ),
                          softWrap: true, // Allow wrapping
                          maxLines: 3, // Allow up to 3 lines
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),

                // Pricing Row - Compact layout
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // MRP (strikethrough)
                      Text(
                        '₹${product.mrp.toInt()}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 1.5,
                        ),
                      ),
                      const SizedBox(width: 3),
                      // Selling Price (bold green)
                      Text(
                        '₹${product.price.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Unit and Deal Badge Row - Compact
                Row(
                  children: [
                    // Unit
                    Expanded(
                      child: Text(
                        'per ${product.unit}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Deal Badge
                    if (product.activeDealUuid != null)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1), // Smaller padding
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius:
                              BorderRadius.circular(6), // Smaller radius
                        ),
                        child: const Text(
                          'DEAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8, // Smaller font
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
