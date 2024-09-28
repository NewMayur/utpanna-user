import 'package:flutter/material.dart';
import '../models/deal.dart';
import '../screens/deal_detail_screen.dart';

class DealCard extends StatelessWidget {
  final Deal deal;

  const DealCard({Key? key, required this.deal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DealDetailScreen(dealId: deal.id),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deal.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(deal.description),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price: \$${deal.price.toStringAsFixed(2)}'),
                  Text('Status: ${deal.status}'),
                ],
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: deal.currentParticipants / deal.minParticipants,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 4),
              Text(
                '${deal.currentParticipants}/${deal.minParticipants} participants',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}