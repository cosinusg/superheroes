import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/pages/superhero_page.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class SuperheroCard extends StatelessWidget {
  final SuperheroInfo superheroInfo;
  final VoidCallback onTap;
  const SuperheroCard({
    Key? key,
    required this.superheroInfo,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: SuperHeroesColors.indigo,
            borderRadius: BorderRadius.circular(8)),
        height: 70,
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              color: Colors.white24,
              height: 70,
              width: 70,
              child: CachedNetworkImage(
                imageUrl: superheroInfo.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) {
                  return Center(
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            color: SuperHeroesColors.blue,
                          )));
                },
                errorWidget: (context, url, dynType) {
                  return Center(child: Image.asset(SuperheroesImages.unknown, width: 20, height: 62, fit:  BoxFit.cover,));
                  },
              ),
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    superheroInfo.name.toUpperCase(),
                    style: TextStyle(
                        color: SuperHeroesColors.whiteText,
                        fontSize: 22,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    superheroInfo.realName,
                    style: TextStyle(
                        color: SuperHeroesColors.whiteText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
