import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'organization.g.dart';

@JsonSerializable()
class Organization extends Equatable {
  Organization(this.id, this.createdAt, this.updatedAt, this.name, this.ownerId);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String ownerId;

  @override
  List<Object> get props => [id];

  factory Organization.fromJson(Map<String, dynamic> json) => _$OrganizationFromJson(json);

  Map<String, dynamic> toJson() => _$OrganizationToJson(this);
}