import 'package:flutter/foundation.dart';

/// Navigation provider for managing bottom navigation state
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void resetToHome() {
    setCurrentIndex(0);
  }
}
