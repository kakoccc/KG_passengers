import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  late SharedPreferences _prefs;

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    _prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _hasSeenWelcome = _prefs.getBool('ff_hasSeenWelcome') ?? false;
    });
  }

  void _safeInit(Function() initializeField) {
    try {
      initializeField();
    } catch (_) {}
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _currentTab = 0;
  int get currentTab => _currentTab;
  set currentTab(int value) {
    _currentTab = value;
  }

  bool _hasSeenWelcome = false;
  bool get hasSeenWelcome => _hasSeenWelcome;
  Future setHasSeenWelcome(bool value) async {
    _hasSeenWelcome = value;
    notifyListeners();
    await _prefs.setBool('ff_hasSeenWelcome', value);
  }
}
