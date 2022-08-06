// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'server_image.g.dart';

@JsonSerializable()
class ServerImage {
  final String url;

  ServerImage(this.url);

  factory ServerImage.fromJson(final Map<String, dynamic> json) => _$ServerImageFromJson(json);
  Map<String, dynamic> toJson() => _$ServerImageToJson(this);

  @override
  bool operator ==(covariant ServerImage other) {
    if (identical(this, other)) return true;
  
    return 
      other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
