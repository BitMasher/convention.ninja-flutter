
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category extends Equatable {
  Category(this.id, this.createdAt, this.updatedAt, this.name, this.organizationId);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String organizationId;

  @override
  List<Object> get props => [id, name, organizationId];

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}