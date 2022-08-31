
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../category/models/category.dart';
import '../../manufacturer/models/manufacturer.dart';


part 'model.g.dart';

@JsonSerializable()
class Model extends Equatable {
  Model(this.id, this.createdAt, this.updatedAt, this.name, this.organizationId, this.manufacturerId, this.categoryId, this.manufacturer, this.category);

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String organizationId;
  final String manufacturerId;
  final String categoryId;
  final Manufacturer? manufacturer;
  final Category? category;

  @override
  String toString() {
    return '${id}\n${name}\n${manufacturer?.name ?? ''}\n${category?.name ?? ''}';
  }

  @override
  List<Object> get props => [id, name, manufacturerId, categoryId, organizationId];

  factory Model.fromJson(Map<String, dynamic> json) => _$ModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelToJson(this);
}