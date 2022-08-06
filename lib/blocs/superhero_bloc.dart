// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/superhero.dart';

class SuperheroBloc {
  http.Client? client;
  final String id;

  // +++++++++++ ?
  final superheroSubject = BehaviorSubject<Superhero>();
  final superheroStateSubject = BehaviorSubject<SuperheroPageState>();

  StreamSubscription? getFromFavoritesSubscription;
  StreamSubscription? replaceFavoritesSubscription;
  StreamSubscription? requestSubscription;
  StreamSubscription? addToFavoriteSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  SuperheroBloc({
    this.client,
    required this.id,
  }) {
    getFromFavorites();
  }

  void getFromFavorites() {
    getFromFavoritesSubscription?.cancel();
    getFromFavoritesSubscription = FavoriteSuperheroesStorage.getInstance()
        .getSuperhero(id)
        .asStream()
        .listen((superhero) {
      if (superhero != null) {
        superheroSubject.add(superhero);
        superheroStateSubject.add(SuperheroPageState.loaded);
      } else {
        superheroStateSubject.add(SuperheroPageState.loading);
      }
      requestSuperhero(superhero != null);
    },
            onError: (error, stackTrace) => print(
                'Error happened in getting favorites: $error, $stackTrace'));
  }

  void addToFavorite() {
    final superhero = superheroSubject.valueOrNull;
    if (superhero == null) {
      print("ERROR: superhero is null while shoudn't be");
      return;
    }
    addToFavoriteSubscription?.cancel();
    addToFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .addToFavorites(superhero)
        .asStream()
        .listen((event) {
      print('Added to favorites: $event');
    },
            onError: (error, stackTrace) =>
                print('Error happened in addToFavorite: $error, $stackTrace'));
  }

  void removeFromFavorites() {
    removeFromFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription = FavoriteSuperheroesStorage.getInstance()
        .removeFromFavorites(id)
        .asStream()
        .listen((event) {
      print('Removed from favorites: $event');
    },
            onError: (error, stackTrace) => print(
                'Error happened in removeFromFavorites: $error, $stackTrace'));
  }

  void retry() {
    superheroStateSubject.add(SuperheroPageState.loading);
    requestSuperhero(false);
  }

  Stream<SuperheroPageState> observeSuperheroPageState() =>
      superheroStateSubject.distinct();

  Stream<bool> observeIsFavorite() =>
      FavoriteSuperheroesStorage.getInstance().observeIsFavorite(id);

  void requestSuperhero(final bool isInFavorites) {
    requestSubscription?.cancel();
    requestSubscription = request().asStream().listen((superhero) {
      if (superheroSubject.valueOrNull != superhero) {
        superheroSubject.add(superhero);
        superheroStateSubject.add(SuperheroPageState.loaded);
      }
    }, onError: (error, stackTrace) {
      if (!isInFavorites) {
        superheroStateSubject.add(SuperheroPageState.error);
      }
      print('Error happened in requestSuperhero: $error, $stackTrace');
    });
  }

  Future<Superhero> request() async {
    final token = dotenv.env['SUPERHERO_TOKEN'];
    final response = await (client ??= http.Client())
        .get(Uri.parse('https://hero.skill-branch.ru/api/$token/$id'));
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    }
    final decoded = json.decode(response.body);
    //print(decoded);
    if (response.statusCode == 200) {
      if (decoded['response'] == 'error') {
        throw ApiException("Client error happened");
      }
    }
    //// +++++++++++
    //if (decoded['response'] == 'success' && decoded['name'] == null) {
    //  return null;
    //}
    //// -----------
    if (decoded['response'] == 'success') {
      final Superhero superhero = Superhero.fromJson(decoded);
      await FavoriteSuperheroesStorage.getInstance().replaceFavorite(superhero);
      return superhero;
    }
    throw Exception("Unknown error happened");
  }

  ///// +++++++++++ ?
  Stream<Superhero> observeSuperhero() => superheroSubject.distinct();

  void dispose() {
    client?.close();
    requestSubscription?.cancel();
    replaceFavoritesSubscription?.cancel();
    addToFavoriteSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    getFromFavoritesSubscription?.cancel();
    superheroSubject.close();
    superheroStateSubject.close();
  }
}

enum SuperheroPageState { loading, loaded, error }
