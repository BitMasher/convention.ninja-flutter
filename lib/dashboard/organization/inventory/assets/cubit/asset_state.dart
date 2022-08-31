part of 'asset_cubit.dart';

enum AssetStatus { pure, inProgress, success, failure }

class AssetState extends Equatable {
  const AssetState(
      {this.serialNumber = '',
      this.manufacturerId = '',
      this.modelId = '',
      this.assetTag = '',
      this.assetTags = const [],
      this.asset,
      this.status = AssetStatus.pure,
      this.errorMessage});

  final String serialNumber;
  final String manufacturerId;
  final String modelId;
  final String assetTag;
  final List<AssetTag> assetTags;
  final Asset? asset;
  final AssetStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => [serialNumber, manufacturerId, modelId, assetTag, assetTags, status, errorMessage];

  AssetState copyWith(
      {String? serialNumber,
      String? manufacturerId,
      String? modelId,
        String? assetTag,
      List<AssetTag>? assetTags,
      Asset? asset,
      AssetStatus? status,
      String? errorMessage}) {
    return AssetState(
        serialNumber: serialNumber ?? this.serialNumber,
        manufacturerId: manufacturerId ?? this.manufacturerId,
        modelId: modelId ?? this.modelId,
        assetTag: assetTag ?? this.assetTag,
        assetTags: assetTags ?? this.assetTags,
        asset: asset ?? this.asset,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
