import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'external_party.g.dart';

@JsonSerializable()
class ExternalParty extends Equatable {
  ExternalParty(this.name, this.extra);

  final String name;
  final String extra;

  factory ExternalParty.fromJson(Map<String, dynamic> json) =>
      _$ExternalPartyFromJson(json);

  Map<String, dynamic> toJson() => _$ExternalPartyToJson(this);

  @override
  List<Object> get props => [name, extra];

  static ExternalParty? nullParser(Map<String, dynamic> json) {
    return json['valid'] ? ExternalParty(json['name'], json['extra']) : null;
  }
}
