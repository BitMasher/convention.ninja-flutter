
import 'package:json_annotation/json_annotation.dart';

part 'update_manufacturer_request.g.dart';

@JsonSerializable()
class UpdateManufacturerRequest {
  UpdateManufacturerRequest(this.name);
  String name;

  Map<String, dynamic> toJson() => _$UpdateManufacturerRequestToJson(this);
}