
import 'package:json_annotation/json_annotation.dart';

part 'update_category_request.g.dart';

@JsonSerializable()
class UpdateCategoryRequest {
  UpdateCategoryRequest(this.name);
  String name;

  Map<String, dynamic> toJson() => _$UpdateCategoryRequestToJson(this);
}