import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superheroes/model/superhero.dart';

class FavoriteSuperheroesStorage {

  static const _key = "favorite_superheroes";

  final updater = PublishSubject<Null>();

  static FavoriteSuperheroesStorage? _instance;
  factory FavoriteSuperheroesStorage.getInstance() => _instance ??= FavoriteSuperheroesStorage._internal();
  FavoriteSuperheroesStorage._internal();

  Future<bool> addToFavorites(final Superhero superhero) async {
    final rawSuperheroes = await _getRawSuperheroes();
    rawSuperheroes.add(json.encode(superhero.toJson()));
    print('SH storage adding');
    return _setRawSuperheroes(rawSuperheroes);
  }

  Future<bool> removeFromFavorites(final String id) async {
    final superheroes = await _getSuperheroes();
    superheroes.removeWhere((superhero) => superhero.id == id);
    return _setSuperheroes(superheroes);
  }

  Future<bool> replaceFavorite(final Superhero newSuperhero) async {
    final superheroes = await _getSuperheroes();
    final index = superheroes.indexWhere((superhero) => superhero.id == newSuperhero.id);
    if (index == -1) {
      return false;
    }
    superheroes[index] = newSuperhero;
    return _setSuperheroes(superheroes); 
  }

  Future<List<String>> _getRawSuperheroes() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_key) ?? []; 
  }

  Future<bool> clearFavorites() async {
    final sp = await SharedPreferences.getInstance();
    return sp.clear();
  }

  Future<bool> _setRawSuperheroes(final List<String> rawSuperheroes) async {
    final sp = await SharedPreferences.getInstance();
    final result = sp.setStringList(_key, rawSuperheroes);
    print('updater $rawSuperheroes');
    updater.add(null);
    return result;
  }

  Future<List<Superhero>> _getSuperheroes() async {
    final rawSuperheroes = await _getRawSuperheroes();
    return rawSuperheroes.map((rawSuperhero) => Superhero.fromJson(json.decode(rawSuperhero))).toList();
  }

  Future<bool> _setSuperheroes(final List<Superhero> superheroes) async {
    final updatedRawSuperheroes = superheroes.map((superhero) => json.encode(superhero.toJson())).toList();
    return _setRawSuperheroes(updatedRawSuperheroes);
  }

  Future<Superhero?> getSuperhero(final String id) async {
    final supeheroes = await _getSuperheroes();
    for (final superhero in supeheroes) {
      if (superhero.id == id) {
        return superhero;
      }
    }
    return null;
  }

  Stream<List<Superhero>> observeFavoriteSuperheros() async* {
    yield await _getSuperheroes();
    await for (final _ in updater) {
      yield await _getSuperheroes();
    }
  }

  Stream<bool> observeIsFavorite(final String id) {
    //print('finding id $id');
    return observeFavoriteSuperheros().map((superheroes) => superheroes.any((superhero) => superhero.id == id));
  }

}