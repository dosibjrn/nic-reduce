import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nicotine_pouch.dart';

/// Maintains the nicotine logic, but data is saved to Firestore per user.
class NicotineProvider extends ChangeNotifier {
  // Basic fields
  double dailyReductionPercentage = 10.0; 
  double currentDosage = 10.0;
  DateTime lastDoseTime = DateTime.now();
  DateTime nextDoseTime = DateTime.now().add(const Duration(hours: 4));

  // Available pouches
  List<NicotinePouch> availablePouches = [
    NicotinePouch(name: 'Mild (4 mg)', mg: 4.0),
    NicotinePouch(name: 'Medium (8 mg)', mg: 8.0),
    NicotinePouch(name: 'Strong (12 mg)', mg: 12.0),
  ];

  double selectedPouchMg = 8.0;

  NicotineProvider() {
    _initFromFirestore();
  }

  // 1) Load user data from Firestore (if logged in)
  Future<void> _initFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      // If no data doc yet, create one with defaults
      await _saveToFirestore();
      return;
    }

    final data = doc.data()!;
    dailyReductionPercentage = (data['dailyReductionPercentage'] ?? 10.0).toDouble();
    currentDosage = (data['currentDosage'] ?? 10.0).toDouble();
    final lastDoseString = data['lastDoseTime'] as String?;
    if (lastDoseString != null) {
      lastDoseTime = DateTime.tryParse(lastDoseString) ?? lastDoseTime;
    }
    final nextDoseString = data['nextDoseTime'] as String?;
    if (nextDoseString != null) {
      nextDoseTime = DateTime.tryParse(nextDoseString) ?? nextDoseTime;
    }
    selectedPouchMg = (data['selectedPouchMg'] ?? 8.0).toDouble();

    notifyListeners();
  }

  // 2) Save user data to Firestore
  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Not logged in
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await docRef.set({
      'dailyReductionPercentage': dailyReductionPercentage,
      'currentDosage': currentDosage,
      'lastDoseTime': lastDoseTime.toIso8601String(),
      'nextDoseTime': nextDoseTime.toIso8601String(),
      'selectedPouchMg': selectedPouchMg,
      // If you want to store the entire list of pouches, you can add that too, or store it statically.
    }, SetOptions(merge: true));
  }

  int get minutesSinceLastDose {
    return DateTime.now().difference(lastDoseTime).inMinutes;
  }

  int get minutesUntilNextDose {
    return nextDoseTime.difference(DateTime.now()).inMinutes;
  }

  void refreshDosage() {
    final now = DateTime.now();
    final elapsedMinutes = now.difference(lastDoseTime).inMinutes;

    if (elapsedMinutes > 0) {
      final dailyTarget = 1.0 - (dailyReductionPercentage / 100.0);
      final exponent = elapsedMinutes / 1440.0; // in days
      final factor = math.pow(dailyTarget, exponent) as double;

      currentDosage = currentDosage * factor;
      lastDoseTime = now;
      _saveToFirestore(); // Save updated dosage
      notifyListeners();
    }
  }

  void takeDose() {
    refreshDosage();
    final hoursSinceLast = minutesSinceLastDose / 60.0;
    if (hoursSinceLast >= 3.0) {
      // UI can suggest milder pouch
    }
    lastDoseTime = DateTime.now();
    nextDoseTime = lastDoseTime.add(const Duration(hours: 4));
    _saveToFirestore();
    notifyListeners();
  }

  void setDailyReduction(double value) {
    dailyReductionPercentage = value;
    _saveToFirestore();
    notifyListeners();
  }

  void setSelectedPouch(double mg) {
    selectedPouchMg = mg;
    _saveToFirestore();
    notifyListeners();
  }

  /// Delete user data from Firestore (GDPR "Delete My Data")
  /// The user might call this from a button in the Settings screen.
  Future<void> deleteUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
  }
}
