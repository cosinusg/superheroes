// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:superheroes/model/biography.dart';
import 'package:superheroes/model/powerstats.dart';
import 'package:superheroes/model/server_image.dart';

part 'superhero.g.dart';

@JsonSerializable()
class Superhero {
  final String id;
  final String name;
  final Biography biography;
  final ServerImage image;
  final Powerstats powerstats;

  Superhero({
    required this.id,
    required this.name,
    required this.biography,
    required this.image,
    required this.powerstats});

  factory Superhero.fromJson(final Map<String, dynamic> json) => _$SuperheroFromJson(json);
  Map<String, dynamic> toJson() => _$SuperheroToJson(this);

  @override
  bool operator ==(covariant Superhero other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.biography == biography &&
      other.image == image &&
      other.powerstats == powerstats;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      biography.hashCode ^
      image.hashCode ^
      powerstats.hashCode;
  }
}
