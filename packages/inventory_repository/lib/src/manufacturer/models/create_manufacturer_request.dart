
import 'package:json_annotation/json_annotation.dart';

part 'create_manufacturer_request.g.dart';

@JsonSerializable()
class CreateManufacturerRequest {
  CreateManufacturerRequest(this.name);
  String name;

  Map<String, dynamic> toJson() => _$CreateManufacturerRequestToJson(this);
}