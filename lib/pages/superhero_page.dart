import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/superhero_bloc.dart';
import 'package:superheroes/model/alignment_info.dart';
import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';
import 'package:superheroes/model/superhero.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_icons.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:http/http.dart' as http;
import 'package:superheroes/widgets/info_with_button.dart';

class SuperheroPage extends StatefulWidget {
  final http.Client? client;
  final String id;

  SuperheroPage({Key? key, this.client, required this.id}) : super(key: key);

  @override
  _SuperheroPageState createState() => _SuperheroPageState();
}

class _SuperheroPageState extends State<SuperheroPage> {
  late SuperheroBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SuperheroBloc(client: widget.client, id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperHeroesColors.background,
        body: SuperheroContentPage(),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class SuperheroContentPage extends StatelessWidget {
  const SuperheroContentPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);

    return StreamBuilder<SuperheroPageState>(
        stream: bloc.observeSuperheroPageState(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          final state = snapshot.data!;
          switch (state) {
            case SuperheroPageState.loading:
              return LoadingSuperheroPage();
            case SuperheroPageState.loaded:
              return FullSuperheroPage();
            case SuperheroPageState.error:
            default:
              return ErrorSuperheroPage();
          }
        });
  }
}

class ErrorSuperheroPage extends StatelessWidget {
  const ErrorSuperheroPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          backgroundColor: SuperHeroesColors.background,
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 60),
            alignment: Alignment.topCenter,
            child: InfoWithButton(
              title: 'Error happened',
              subtitle: 'Please, try again',
              buttonText: 'Retry',
              assetImage: SuperheroesImages.superman,
              imageHeight: 106,
              imageWidth: 126,
              imageTopPadding: 22,
              onTap: () {
                bloc.retry();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingSuperheroPage extends StatelessWidget {
  const LoadingSuperheroPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          elevation: 0,
          backgroundColor: SuperHeroesColors.background,
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 60),
            alignment: Alignment.topCenter,
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              color: SuperHeroesColors.blue,
            ),
          ),
        ),
      ],
    );
  }
}

class FullSuperheroPage extends StatelessWidget {
  const FullSuperheroPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<Superhero>(
        stream: bloc.observeSuperhero(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return SizedBox.shrink();
          }
          final superhero = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SuperheroAppBar(superhero: superhero),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    if (superhero.powerstats.isNotNull())
                      PowerstatsWidget(
                        powerstats: superhero.powerstats,
                      ),
                    BiographyWidget(biography: superhero.biography),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class SuperheroAppBar extends StatelessWidget {
  const SuperheroAppBar({
    Key? key,
    required this.superhero,
  }) : super(key: key);

  final Superhero superhero;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      stretch: true,
      pinned: true,
      floating: true,
      expandedHeight: 348,
      actions: [FavoriteButton()],
      backgroundColor: SuperHeroesColors.background,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          superhero.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        background: CachedNetworkImage(
          imageUrl: superhero.image.url,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            return ColoredBox(
              color: SuperHeroesColors.indigo,
            );
          },
          errorWidget: (context, url, error) {
            return Container(
              color: SuperHeroesColors.indigo,
              alignment: Alignment.center,
              child: Image.asset(
                SuperheroesImages.unknownBig,
                width: 85,
                height: 264,
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavoriteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<SuperheroBloc>(context, listen: false);
    return StreamBuilder<bool>(
        stream: bloc.observeIsFavorite(),
        initialData: false,
        builder: (context, snapshot) {
          final favorite =
              !snapshot.hasData || snapshot.data == null || snapshot.data!;
          return GestureDetector(
            onTap: () =>
                favorite ? bloc.removeFromFavorites() : bloc.addToFavorite(),
            child: Container(
              height: 52,
              width: 52,
              alignment: Alignment.center,
              child: Image.asset(
                favorite
                    ? SuperheroesIcons.starFilled
                    : SuperheroesIcons.starEmpty,
                height: 32,
                width: 32,
              ),
            ),
          );
        });
  }
}

class PowerstatsWidget extends StatelessWidget {
  final Powerstats powerstats;
  const PowerstatsWidget({Key? key, required this.powerstats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powerstats'.toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.w700, color: Colors.white, fontSize: 18),
        ),
        SizedBox(
          height: 24,
        ),
        Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Intelligence',
                value: powerstats.intelligencePercent,
              ),
            )),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Strength',
                value: powerstats.strengthPercent,
              ),
            )),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Speed',
                value: powerstats.speedPercent,
              ),
            )),
            SizedBox(
              width: 16,
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Durability',
                value: powerstats.durabilityPercent,
              ),
            )),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Power',
                value: powerstats.powerPercent,
              ),
            )),
            Expanded(
                child: Center(
              child: PowerstatWidget(
                name: 'Combat',
                value: powerstats.combatPercent,
              ),
            )),
            SizedBox(
              width: 16,
            ),
          ],
        ),
        SizedBox(
          height: 36,
        ),
      ],
    );
  }
}

class PowerstatWidget extends StatelessWidget {
  final String name;
  final double value;
  const PowerstatWidget({
    Key? key,
    required this.name,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ArcWidget(value: value, color: calculateColorByValue()),
        Padding(
          padding: const EdgeInsets.only(top: 17),
          child: Text(
            '${(value * 100).toInt()}',
            style: TextStyle(
              color: calculateColorByValue(),
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 44),
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Color calculateColorByValue() {
    if (value <= 0.5) {
      return Color.lerp(Colors.red, Colors.orangeAccent, value / 0.5)!;
    } else {
      return Color.lerp(Colors.orangeAccent, Colors.green, value / 0.5)!;
    }
  }
}

class ArcWidget extends StatelessWidget {
  final double value;
  final Color color;
  const ArcWidget({Key? key, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArcCustomPainter(value, color),
      size: Size(66, 33),
    );
  }
}

class ArcCustomPainter extends CustomPainter {
  final double value;
  final Color color;

  ArcCustomPainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    final backgroundPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;
    canvas.drawArc(rect, pi, pi, false, backgroundPaint);
    canvas.drawArc(rect, pi, pi * value, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is ArcCustomPainter) {
      return oldDelegate.value != value && oldDelegate.color != color;
    }
    return true;
  }
}

class BiographyWidget extends StatelessWidget {
  final Biography biography;
  const BiographyWidget({Key? key, required this.biography}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
          color: SuperHeroesColors.indigo,
          borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Bio'.toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                //SizedBox(
                //  height: 8,
                //),
                BioTextBloc(
                    header: 'Full name'.toUpperCase(),
                    body: biography.fullName),
                SizedBox(
                  height: 20,
                ),
                BioTextBloc(
                    header: 'Aliases'.toUpperCase(),
                    body: biography.aliases.join(', ')),
                SizedBox(
                  height: 20,
                ),
                BioTextBloc(
                    header: 'Place of birth'.toUpperCase(),
                    body: biography.placeOfBirth),
              ],
            ),
          ),
          if (biography.alignment != null)
            Align(
              alignment: Alignment.topRight,
              child: AlignmentWidget(
                alignmentInfo:
                    AlignmentInfo.fromAlingment(biography.alignment)!,
              ),
            ),
        ],
      ),
    );
  }
}

class BioTextBloc extends StatelessWidget {
  final String header;
  final String body;
  const BioTextBloc({Key? key, required this.header, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: TextStyle(
              color: Color.fromRGBO(153, 153, 153, 1),
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          body,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
        )
      ],
    );
  }
}

class AlignmentWidget extends StatelessWidget {
  final AlignmentInfo alignmentInfo;
  const AlignmentWidget({Key? key, required this.alignmentInfo})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        //color: alignmentInfo.color,
        decoration: BoxDecoration(
            color: alignmentInfo.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )),
        alignment: Alignment.center,
        width: 70,
        height: 24,
        child: Text(
          alignmentInfo.name.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
