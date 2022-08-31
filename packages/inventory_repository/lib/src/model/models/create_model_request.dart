
import 'package:json_annotation/json_annotation.dart';

part 'create_model_request.g.dart';

@JsonSerializable()
class CreateModelRequest {
  CreateModelRequest(this.name, this.categoryId, this.manufacturerId);
  String name;
  String categoryId;
  String manufacturerId;

  Map<String, dynamic> toJson() => _$CreateModelRequestToJson(this);
}