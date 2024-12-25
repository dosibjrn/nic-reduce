import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nicotine_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NicotineProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Daily reduction: ${provider.dailyReductionPercentage.toStringAsFixed(2)} %',
            style: const TextStyle(fontSize: 16),
          ),
          Slider(
            value: provider.dailyReductionPercentage,
            min: 0,
            max: 50,
            divisions: 50,
            label: '${provider.dailyReductionPercentage.toStringAsFixed(0)} %',
            onChanged: (val) {
              provider.setDailyReduction(val);
            },
          ),
          const Divider(),
          const Text(
            'Available Pouches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...provider.availablePouches.map((pouch) {
            return RadioListTile<double>(
              title: Text('${pouch.name} (${pouch.mg} mg)'),
              value: pouch.mg,
              groupValue: provider.selectedPouchMg,
              onChanged: (val) {
                if (val != null) {
                  provider.setSelectedPouch(val);
                }
              },
            );
          }).toList(),
          const SizedBox(height: 20),
          Text(
            'Selected pouch: ${provider.selectedPouchMg.toStringAsFixed(1)} mg',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          // GDPR basic approach: "Delete my data"
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete My Data'),
            onPressed: () async {
              await provider.deleteUserData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your data has been deleted.')),
              );
            },
          )
        ],
      ),
    );
  }
}
