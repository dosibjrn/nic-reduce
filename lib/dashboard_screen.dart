import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/nicotine_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NicotineProvider>(context);
    provider.refreshDosage();

    final hoursSinceLast = provider.minutesSinceLastDose / 60.0;
    final showSuggestion = hoursSinceLast >= 3.0;
    final minutesUntilNext = provider.minutesUntilNextDose;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Current dosage: ${provider.currentDosage.toStringAsFixed(2)} mg',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            'Last dose was ${hoursSinceLast.toStringAsFixed(1)} hours ago.',
          ),
          const SizedBox(height: 10),
          Text(
            'Next dose in approx. $minutesUntilNext minutes.',
          ),
          if (showSuggestion)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              padding: const EdgeInsets.all(12.0),
              color: Colors.amber[200],
              child: const Text(
                'You went more than 3 hours without a dose.\nConsider using a milder pouch next time!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Take Dose'),
            onPressed: () {
              provider.takeDose();
            },
          ),
        ],
      ),
    );
  }
}
