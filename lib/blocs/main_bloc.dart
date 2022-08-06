// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

import 'package:superheroes/exception/api_exception.dart';
import 'package:superheroes/favorite_superheroes_storage.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/superhero.dart';

class MainBloc {
  static const minSymbols = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded('');

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;
  StreamSubscription? removeFromFavoriteSubscription;

  http.Client? client;

  FocusNode? focusNode;

  MainBloc({this.client}) {
    textSubscription =
        Rx.combineLatest2<String, List<Superhero>, MainPageStateInfo>(
            currentTextSubject
                .distinct()
                .debounceTime(Duration(milliseconds: 500)),
            FavoriteSuperheroesStorage.getInstance().observeFavoriteSuperheros(),
            (searchText, favorites) =>
                MainPageStateInfo(searchText, favorites.isNotEmpty)).listen(
            (value) {
      print('Changed $value');
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchedSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() =>
      FavoriteSuperheroesStorage.getInstance().observeFavoriteSuperheros().map(
          (superheroes) => superheroes
              .map((superhero) => SuperheroInfo.fromSuperhero(superhero))
              .toList());
  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() =>
      searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    final token = dotenv.env['SUPERHERO_TOKEN'];
    final response = await (client ??= http.Client())
        .get(Uri.parse('https://hero.skill-branch.ru/api/$token/search/$text'));
    if (response.statusCode >= 500 && response.statusCode <= 599) {
      throw ApiException("Server error happened");
    } else if (response.statusCode >= 400 && response.statusCode <= 499) {
      throw ApiException("Client error happened");
    }
    final decoded = json.decode(response.body);
    print(decoded);
    if (response.statusCode == 200) {
      if (decoded['response'] == 'error' &&
          decoded['error'] != 'character with given name not found') {
        throw ApiException("Client error happened");
      }
    }
    if (decoded['response'] == 'success') {
      final List<dynamic> results = decoded['results'];
      if (results.isEmpty) {
        return [];
      }
      final List<Superhero> superheroes = results
          .map((rawSuperhero) => Superhero.fromJson(rawSuperhero))
          .toList();
      final List<SuperheroInfo> found = superheroes.map((superhero) {
        return SuperheroInfo.fromSuperhero(superhero);
      }).toList();
      return found;
    }
    throw Exception("Unknown error happened");
  }

  Stream<MainPageState> observMainPageState() => stateSubject;

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? '');
  }

  //void removeFavorite() {
  //  final List<SuperheroInfo> currentFavorites =
  //      favoriteSuperheroesSubject.value;
  //  if (currentFavorites.isEmpty) {
  //    favoriteSuperheroesSubject.add(SuperheroInfo.mocked);
  //  } else {
  //    favoriteSuperheroesSubject
  //        .add(currentFavorites.sublist(0, currentFavorites.length - 1));
  //  }
  //}

  void removeFromFavorites(final String id) {
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
    searchForSuperheroes(currentTextSubject.value);
  }

  void dispose() {
    stateSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();
    textSubscription?.cancel();
    searchSubscription?.cancel();
    removeFromFavoriteSubscription?.cancel();
    client?.close();
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

class SuperheroInfo {
  final String id;
  final String name;
  final String realName;
  final String imageUrl;
  final AlignmentInfo? alignmentInfo;
  const SuperheroInfo(
      {required this.name,
      required this.realName,
      required this.imageUrl,
      required this.id,
      this.alignmentInfo});

  factory SuperheroInfo.fromSuperhero(final Superhero superhero) {
    return SuperheroInfo(
        id: superhero.id,
        name: superhero.name,
        realName: superhero.biography.fullName,
        imageUrl: superhero.image.url,
        alignmentInfo: superhero.biography.alignmentInfo);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SuperheroInfo &&
        other.id == id &&
        other.name == name &&
        other.realName == realName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;
  }

  @override
  String toString() {
    return 'SuperheroInfo(id: $id, name: $name, realName: $realName, imageUrl: $imageUrl)';
  }

  static const mocked = [
    SuperheroInfo(
      id: "70",
      name: 'Batman',
      realName: 'Bruce Wayne',
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      id: "732",
      name: 'Ironman',
      realName: 'Tony Stark',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
    ),
    SuperheroInfo(
      id: "687",
      name: 'Venom',
      realName: 'Eddie Brock',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
    ),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;
  const MainPageStateInfo(
    this.searchText,
    this.haveFavorites,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MainPageStateInfo &&
        other.searchText == searchText &&
        other.haveFavorites == haveFavorites;
  }

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;

  @override
  String toString() =>
      'MainPageStateInfo(searchText: $searchText, haveFavorites: $haveFavorites)';
}
