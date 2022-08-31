part of 'manifest_cubit.dart';

enum ManifestStatus { pure, inProgress, failure, success }

class ManifestState extends Equatable {
  ManifestState(
      {this.roomId = '',
      this.name = '',
      this.extra = '',
      this.tagId = '',
      required this.manifest,
      this.status = ManifestStatus.pure,
      this.errorMessage});

  final String roomId;
  final String name;
  final String extra;
  final String tagId;
  final Manifest manifest;
  final ManifestStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [roomId, name, extra, tagId, status, errorMessage];

  ManifestState copyWith(
      {String? roomId,
      String? name,
      String? extra,
      String? tagId,
      Manifest? manifest,
      ManifestStatus? status,
      String? errorMessage}) {
    return ManifestState(
        roomId: roomId ?? this.roomId,
        name: name ?? this.name,
        extra: extra ?? this.extra,
        tagId: tagId ?? this.tagId,
        manifest: manifest ?? this.manifest,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
