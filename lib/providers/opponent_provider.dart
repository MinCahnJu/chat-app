import 'package:flutter/foundation.dart';

class Opponent {
  final String name;

  Opponent({
    required this.name,
  });
}

class OpponentProvider with ChangeNotifier {
  Opponent? _opponent;

  Opponent? get opponent => _opponent;

  void setOpponent(Opponent opponent) {
    _opponent = opponent;
    notifyListeners();
  }

  void clearOpponent() {
    _opponent = null;
    notifyListeners();
  }
}
