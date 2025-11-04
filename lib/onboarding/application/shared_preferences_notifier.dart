import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesNotifier extends ChangeNotifier {
  SharedPreferencesNotifier({
    required this.prefs,
  });

  final SharedPreferences prefs;

  final String _keyForHasAlreadySeenTheIrrstPage = 'hasAlreadySeenTheIrrstPage';
  final String _keyForHasSeenOnboarding = 'hasSeenOnboarding';

  Future<bool> get hasAlreadySeenTheIrrstPage async {
    return prefs.getBool(_keyForHasAlreadySeenTheIrrstPage) ??
        await prefs
            .setBool(_keyForHasAlreadySeenTheIrrstPage, false)
            .whenComplete(
              () => notifyListeners(),
            );
  }

  Future<bool> get hasSeenOnboarding async {
    return prefs.getBool(_keyForHasSeenOnboarding) ??
        await prefs.setBool(_keyForHasSeenOnboarding, false).whenComplete(
              () => notifyListeners(),
            );
  }

  Future<void> setHasSeenOnboardingTo(bool value) async {
    await prefs.setBool(_keyForHasSeenOnboarding, value);
    notifyListeners();
  }

  Future<void> sethasAlreadySeenTheIrrstPage(bool value) async {
    await prefs.setBool(_keyForHasAlreadySeenTheIrrstPage, value);
    notifyListeners();
  }
}
