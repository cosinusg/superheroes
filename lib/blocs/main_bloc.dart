import 'dart:async';

import 'package:rxdart/subjects.dart';

class MainBloc {
  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();

  Stream<MainPageState> observMainPageState() => stateSubject;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);
  }

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void dispose() {
    stateSubject.close();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites,
}
