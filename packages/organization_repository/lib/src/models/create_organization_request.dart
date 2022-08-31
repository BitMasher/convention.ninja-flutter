
import 'package:json_annotation/json_annotation.dart';

part 'create_organization_request.g.dart';

@JsonSerializable()
class CreateOrganizationRequest {
  CreateOrganizationRequest(this.name);
  final String name;
  Map<String, dynamic> toJson() => _$CreateOrganizationRequestToJson(this);
}