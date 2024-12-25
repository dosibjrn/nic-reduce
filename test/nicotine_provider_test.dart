import 'package:flutter_test/flutter_test.dart';
import 'package:my_nicotine_app/providers/nicotine_provider.dart';

void main() {
  group('NicotineProvider Tests', () {
    test('Default values', () {
      final provider = NicotineProvider();
      expect(provider.dailyReductionPercentage, 10.0);
      expect(provider.currentDosage, 10.0);
    });

    test('refreshDosage lowers dosage after 24h by 10%', () {
      final provider = NicotineProvider();
      provider.currentDosage = 100.0;
      final now = DateTime.now();
      provider.lastDoseTime = now.subtract(const Duration(hours: 24));
      provider.refreshDosage();
      expect(provider.currentDosage, closeTo(90.0, 0.5));
    });
  });
}
