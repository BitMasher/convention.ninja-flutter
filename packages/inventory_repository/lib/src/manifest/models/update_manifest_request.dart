
import 'package:json_annotation/json_annotation.dart';

import 'external_party.dart';

part 'update_manifest_request.g.dart';

@JsonSerializable()
class UpdateManifestRequest {
  UpdateManifestRequest(this.roomId, this.responsibleExternalParty);

  String roomId;
  ExternalParty responsibleExternalParty;

  Map<String, dynamic> toJson() => _$UpdateManifestRequestToJson(this);
}