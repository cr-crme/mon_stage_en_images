import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesNotifier extends ChangeNotifier {
  SharedPreferencesNotifier({
    required this.prefs,
  });

  final SharedPreferences prefs;

  final String _nameForHasAlreadySeenTheIrrstPage =
      "hasAlreadySeenTheIrrstPage";
  final String _nameForHasSeenOnboarding = "hasSeenOnboarding";

  Future<bool> get hasAlreadySeenTheIrrstPage async {
    return prefs.getBool(_nameForHasAlreadySeenTheIrrstPage) ??
        await prefs
            .setBool(_nameForHasAlreadySeenTheIrrstPage, false)
            .whenComplete(
              () => notifyListeners(),
            );
  }

  Future<bool> get hasSeenOnboarding async {
    return prefs.getBool(_nameForHasSeenOnboarding) ??
        await prefs.setBool(_nameForHasSeenOnboarding, false).whenComplete(
              () => notifyListeners(),
            );
  }

  Future<void> setHasSeenOnboardingTo(bool value) async {
    await prefs.setBool(_nameForHasSeenOnboarding, value);
    notifyListeners();
  }

  Future<void> sethasAlreadySeenTheIrrstPage(bool value) async {
    await prefs.setBool(_nameForHasAlreadySeenTheIrrstPage, value);
    notifyListeners();
  }
}
