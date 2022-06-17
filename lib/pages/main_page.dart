import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperHeroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return Stack(
      children: [
        MainPageStateWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ActionButton(
              onTap: () => bloc.nextState(),
              text: 'Next state',
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperHeroesColors.blue,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<MainPageState>(
      stream: bloc.observMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.noFavorites:
            return InfoWithButton(
              title: 'No favorites yet',
              subtitle: 'Search and add',
              buttonText: 'Search',
              assetImage: SuperheroesImages.ironMan,
              imageHeight: 119,
              imageWidth: 108,
              imageTopPadding: 9,
            );
          case MainPageState.minSymbols:
            return MinSymbolsWidget();
          case MainPageState.nothingFound:
            return InfoWithButton(
              title: 'Nothing found',
              subtitle: 'Search for something else',
              buttonText: 'Search',
              assetImage: SuperheroesImages.hulk,
              imageHeight: 112,
              imageWidth: 84,
              imageTopPadding: 16,
            );
          case MainPageState.loadingError:
            return InfoWithButton(
              title: 'Error happened',
              subtitle: 'Please, try again',
              buttonText: 'Retry',
              assetImage: SuperheroesImages.superman,
              imageHeight: 106,
              imageWidth: 126,
              imageTopPadding: 22,
            );
          case MainPageState.searchResults:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Search results',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: SuperHeroesColors.whiteText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SuperheroCard(
                    name: 'Batman',
                    realName: 'Bruce Wayne',
                    imageUrl:
                        'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SuperheroCard(
                    name: 'Venom',
                    realName: 'Eddie Brock',
                    imageUrl:
                        'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
                  ),
                ),
              ],
            );
          case MainPageState.favorites:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Your favorites',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: SuperHeroesColors.whiteText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SuperheroCard(
                    name: 'Batman',
                    realName: 'Bruce Wayne',
                    imageUrl:
                        'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SuperheroCard(
                    name: 'Ironman',
                    realName: 'Tony Stark',
                    imageUrl:
                        'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
                  ),
                ),
              ],
            );
          default:
            return Center(
                child: Text(
              snapshot.data.toString(),
              style: TextStyle(
                color: Colors.white,
              ),
            ));
        }
      },
    );
  }
}

class MinSymbolsWidget extends StatelessWidget {
  const MinSymbolsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: 110,
        ),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            color: SuperHeroesColors.whiteText,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
