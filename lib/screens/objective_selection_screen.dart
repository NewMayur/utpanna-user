import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/combo_provider.dart';
import '../screens/combo_recommendation_screen.dart';

class ObjectiveSelectionScreen extends StatelessWidget {
  const ObjectiveSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ComboBuilderProvider>(context);
    final selectedCrop = provider.selectedCrop;

    if (selectedCrop == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Objective'),
        ),
        body: const Center(
          child: Text('No crop selected. Please go back.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Objectives for ${selectedCrop.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your farming objective to get personalized product recommendations',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: provider.farmingData!.objectives.length,
                itemBuilder: (context, index) {
                  final objective = provider.farmingData!.objectives[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        objective.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        provider.selectObjective(objective);

                        // Always navigate to combo recommendation screen
                        // Screen will show products categorized even without deals
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ComboRecommendationScreen(),
                          ),
                        );
                      },
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
}
