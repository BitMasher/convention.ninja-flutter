import 'package:json_annotation/json_annotation.dart';

part 'update_asset_request.g.dart';

@JsonSerializable()
class UpdateAssetRequest {
  UpdateAssetRequest(this.modelId, this.roomId, this.serialNumber);

  @JsonKey(includeIfNull: false)
  String? modelId;
  @JsonKey(includeIfNull: false)
  String? roomId;
  @JsonKey(includeIfNull: false)
  String? serialNumber;

  @JsonKey(ignore: true)
  bool get isEmpty =>
      (modelId == null || modelId?.isEmpty == true) &&
      (roomId == null || roomId?.isEmpty == true) &&
      (serialNumber == null || serialNumber?.isEmpty == true);

  Map<String, dynamic> toJson() => _$UpdateAssetRequestToJson(this);
}
