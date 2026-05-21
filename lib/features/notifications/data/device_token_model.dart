import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_model.freezed.dart';
part 'device_token_model.g.dart';

@freezed
abstract class DeviceTokenModel with _$DeviceTokenModel {
  const factory DeviceTokenModel({
    required String id,
    required String userId,
    required String token,
    required String platform,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DeviceTokenModel;

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenModelFromJson(json);
}
