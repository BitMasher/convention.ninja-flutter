
import 'package:json_annotation/json_annotation.dart';

part 'create_category_request.g.dart';

@JsonSerializable()
class CreateCategoryRequest {
  CreateCategoryRequest(this.name);
  String name;

  Map<String, dynamic> toJson() => _$CreateCategoryRequestToJson(this);
}