import 'package:json_annotation/json_annotation.dart';

part 'create_barcode_request.g.dart';

@JsonSerializable()
class CreateBarcodeRequest {
  CreateBarcodeRequest(this.tagId);

  String tagId;

  Map<String, dynamic> toJson() => _$CreateBarcodeRequestToJson(this);
}
