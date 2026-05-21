// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceTokenModel _$DeviceTokenModelFromJson(Map<String, dynamic> json) =>
    _DeviceTokenModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      token: json['token'] as String,
      platform: json['platform'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$DeviceTokenModelToJson(_DeviceTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'token': instance.token,
      'platform': instance.platform,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
