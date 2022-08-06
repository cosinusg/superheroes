// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'powerstats.g.dart';

@JsonSerializable()
class Powerstats {
  final String intelligence;
  final String strength;
  final String speed;
  final String durability;
  final String power;
  final String combat;

  Powerstats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
});

  bool isNotNull() => 
      intelligence != 'null' && 
      strength != 'null' &&
      speed != 'null' &&
      durability != 'null' &&
      power != 'null' &&
      combat != 'null';

  double get intelligencePercent => convertStringToPercent(intelligence);
  double get strengthPercent => convertStringToPercent(strength);
  double get speedPercent => convertStringToPercent(speed);
  double get durabilityPercent => convertStringToPercent(durability);
  double get powerPercent => convertStringToPercent(power);
  double get combatPercent => convertStringToPercent(combat);

  double convertStringToPercent(final String value){
    final intValue = int.tryParse(value);
    if (intValue == null) return 0;
    return intValue/100;
  }

  factory Powerstats.fromJson(final Map<String, dynamic> json) => _$PowerstatsFromJson(json);
  Map<String, dynamic> toJson() => _$PowerstatsToJson(this);

  @override
  bool operator ==(covariant Powerstats other) {
    if (identical(this, other)) return true;
  
    return 
      other.intelligence == intelligence &&
      other.strength == strength &&
      other.speed == speed &&
      other.durability == durability &&
      other.power == power &&
      other.combat == combat;
  }

  @override
  int get hashCode {
    return intelligence.hashCode ^
      strength.hashCode ^
      speed.hashCode ^
      durability.hashCode ^
      power.hashCode ^
      combat.hashCode;
  }
}
