import 'package:json_annotation/json_annotation.dart';

part 'update_model_request.g.dart';

@JsonSerializable()
class UpdateModelRequest {
  UpdateModelRequest(this.name, this.categoryId, this.manufacturerId);

  @JsonKey(includeIfNull: false)
  String? name;
  @JsonKey(includeIfNull: false)
  String? categoryId;
  @JsonKey(includeIfNull: false)
  String? manufacturerId;

  @JsonKey(ignore: true)
  bool get isEmpty =>
      (name == null || name?.isEmpty == true) &&
      (categoryId == null || categoryId?.isEmpty == true) &&
      (manufacturerId == null || manufacturerId?.isEmpty == true);

  Map<String, dynamic> toJson() => _$UpdateModelRequestToJson(this);
}
