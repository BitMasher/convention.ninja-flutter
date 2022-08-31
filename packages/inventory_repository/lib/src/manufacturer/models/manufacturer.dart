
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'manufacturer.g.dart';

@JsonSerializable()
class Manufacturer extends Equatable {
  Manufacturer(this.id, this.createdAt, this.updatedAt, this.name, this.organizationId);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String organizationId;

  @override
  List<Object> get props => [id, name, organizationId];

  factory Manufacturer.fromJson(Map<String, dynamic> json) => _$ManufacturerFromJson(json);

  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}