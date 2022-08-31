
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_user.g.dart';

@JsonSerializable()
class ApiUser extends Equatable {
  ApiUser(this.id, this.createdAt, this.updatedAt, this.name, this.displayName, this.email);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String displayName;
  final String email;

  List<Object> get props => [this.id, this.name, this.displayName, this.email];

  factory ApiUser.fromJson(Map<String, dynamic> json) => _$ApiUserFromJson(json);

  Map<String, dynamic> toJson() => _$ApiUserToJson(this);
}