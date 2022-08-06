import 'package:flutter/cupertino.dart';
import 'package:superheroes/resources/superheroes_colors.dart';

class AlignmentInfo {
  final String name;
  final Color color;

  const AlignmentInfo._(this.name, this.color);

  static const bad = AlignmentInfo._('bad', SuperHeroesColors.red);
  static const good = AlignmentInfo._('good', SuperHeroesColors.green);
  static const neutral = AlignmentInfo._('neutral', SuperHeroesColors.grey);
  
  static AlignmentInfo? fromAlingment (final String alignment) {
    if (alignment == 'bad') {
      return bad;
    } else if (alignment == 'good') {
      return good;
    } else if (alignment == 'neutral') {
      return neutral;
    }
    return null;
  }

}