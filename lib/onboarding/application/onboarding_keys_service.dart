import 'package:flutter/cupertino.dart';

///Source of truth for GlobalKeys used during the onboarding sequences.
///It registers two types of keys : screenKeys ( GlobalKey`<State<StatefulWidget>>` ) and OnboardingTarget keys
///( non typed GlobalKey ), each inside
class OnboardingKeysService {
  ///Map for the OnboardingTarget keys. These keys links an OnboardingTarget with its OnboardingStep object
  final Map<String, GlobalKey> _keysMap = {};

  ///Map for the screenKeys, registered when generating a route (see main : onGeneratedRoute and onInitialGeneratedRoute)
  final Map<String, GlobalKey<State<StatefulWidget>>> _screenKeysMap = {};
  OnboardingKeysService._();

  ///Not in use currently
  final Map<String, GlobalKey> _intermediateKeys = {};
  static final OnboardingKeysService instance = OnboardingKeysService._();

  void addTargetKey(String id, GlobalKey key) {
    //checking for duplicate
    if (_keysMap[id] != null && _keysMap[id] != key) {
      debugPrint('Global Key with id $id duplicate in OnBoardingKeyService');
    }
    _keysMap[id] = key;
    debugPrint("new key added : ${_keysMap[id]}");
  }

  void removeTargetKey(String id, GlobalKey key) {
    if (_keysMap[id] != null && _keysMap[id] == key) _keysMap.remove(id);
  }

  GlobalKey? findTargetKeyWithId(String id) => _keysMap[id];

  void addScreenKey(String id, GlobalKey<State<StatefulWidget>> key) {
    //checking for duplicate
    if (_screenKeysMap[id] != null && _screenKeysMap[id] != key) {
      debugPrint('Global Key with id $id duplicate in OnBoardingKeyService');
    }
    _screenKeysMap[id] = key;
    debugPrint("new key added in screenKeysMap for$id : ${_screenKeysMap[id]}");
  }

//TODO check duplicate
  void addIntermediateKey(String id, GlobalKey key) =>
      _intermediateKeys[id] = key;

  void removeScreenKey(String id, GlobalKey<State<StatefulWidget>> key) {
    if (_screenKeysMap[id] != null && _screenKeysMap[id] == key) {
      _screenKeysMap.remove(id);
    }
  }

  GlobalKey? findScreenKeyWithId(String id) => _screenKeysMap[id];
  GlobalKey? findIntermediateKey(String id) => _intermediateKeys[id];
}

//TODO add removeIntermediateKeys
