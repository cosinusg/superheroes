import 'package:json_annotation/json_annotation.dart';
import 'package:superheroes/model/alignment_info.dart';

part 'biography.g.dart';

@JsonSerializable()
class Biography {
  final String fullName;
  final String alignment;
  final List<String> aliases;
  final String placeOfBirth;

  Biography({
    required this.fullName,
    required this.alignment,
    required this.aliases,
    required this.placeOfBirth});

  factory Biography.fromJson(final Map<String, dynamic> json) => _$BiographyFromJson(json);
  Map<String, dynamic> toJson() => _$BiographyToJson(this);

  AlignmentInfo? get alignmentInfo => AlignmentInfo.fromAlingment(alignment);
}